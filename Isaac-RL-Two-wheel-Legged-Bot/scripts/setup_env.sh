#!/usr/bin/env bash
# =============================================================================
# 一键重建 Flamingo 训练环境（新人 / 新机器用）
#
# 用法：
#   ./setup_env.sh                 # 在仓库根目录执行
#   ENV_DIR=/path/to/env ./setup_env.sh   # 自定义 venv 位置（默认仓库上级的 env_isaaclab）
#   FRESH=1 ./setup_env.sh         # 目标 venv 已存在时：备份旧环境后全新重建（修复环境用）
#
# 会做 5 件事：
#   1. 创建 Python 3.10 虚拟环境（优先 uv，退而用 python3.10 -m venv）
#   2. 从 PyTorch 官方 cu128 源安装 torch 2.7.0+cu128
#   3. 从 requirements.txt 安装其余依赖（isaacsim 走 NVIDIA 源，约 20GB，耐心等）
#   4. 以 editable 方式安装 IsaacLab（5 个子包，固定 commit）与 lab.flamingo
#   5. 验证 import isaacsim / torch
#
# 说明：
#   * 不要直接打包 env_isaaclab 目录给同事——里面有写死本机路径的 editable 安装。
#   * requirements.txt + 本脚本 才是可移植的环境定义。
#   * ⚠️ 绝对不要对现有 venv 跑 `uv pip sync -r requirements.txt` 或
#     `uv pip install -r requirements.txt`：requirements.txt 刻意不含 torch/editable，
#     会把现有环境拆坏（本项目已实际踩坑）。要全量同步请用 requirements-full.txt。
#   * ROS 2 依赖（isaacsim-ros1/ros2、rclpy、action-msgs 等 78 个包）已从清单剔除：
#     它们的源（pypi.ros.org）不可用，且训练 / ONNX 部署用不到。日后如需 ROS 接口，
#     单独安装 isaacsim[ros2]（见 NVIDIA 官方文档）。
# =============================================================================
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_DIR="${ENV_DIR:-$(dirname "$REPO_DIR")/env_isaaclab}"
ISAACLAB_GIT="git+https://github.com/isaac-sim/IsaacLab.git@3c6e67bb5c7ada942a6d1884ab69338f57596f77"

echo "[INFO] 仓库目录 : $REPO_DIR"
echo "[INFO] venv 目录 : $ENV_DIR"

# ---------- 0. 处理已存在的 venv ----------
if [ -d "$ENV_DIR" ] && [ -n "$(ls -A "$ENV_DIR" 2>/dev/null)" ]; then
    if [ "${FRESH:-0}" = "1" ]; then
        BAK="${ENV_DIR}_bak_$(date +%Y%m%d_%H%M%S)"
        echo "[WARN] 检测到已有环境，备份为 $BAK 后全新重建 ..."
        mv "$ENV_DIR" "$BAK"
    else
        echo "[WARN] 检测到已有环境 $ENV_DIR，将【复用】（不会清理旧包）。"
        echo "       若环境损坏想全新重建，请用：FRESH=1 ./setup_env.sh（旧环境自动备份为 *_bak_*）"
    fi
fi

# ---------- 1. 创建 venv ----------
if command -v uv >/dev/null 2>&1; then
    echo "[1/5] 使用 uv 创建虚拟环境 ..."
    uv venv "$ENV_DIR" --python 3.10
    PY="$ENV_DIR/bin/python"
    PIP="uv pip install --python $PY"
else
    echo "[1/5] 未找到 uv，回退到 python3.10 -m venv ..."
    python3.10 -m venv "$ENV_DIR"
    PY="$ENV_DIR/bin/python"
    PIP="$PY -m pip install --upgrade pip && $PY -m pip install"
fi

# ---------- 2. torch（cu128，PyTorch 官方源） ----------
echo "[2/5] 安装 torch 2.7.0+cu128 / torchvision 0.22.0+cu128 ..."
$PIP --index-url https://download.pytorch.org/whl/cu128 \
    torch==2.7.0+cu128 torchvision==0.22.0+cu128

# ---------- 3. 其余依赖（isaacsim 来自 NVIDIA 源） ----------
echo "[3/5] 安装 requirements.txt（含 Isaac Sim 4.5，约 20GB，请耐心等待）..."
$PIP --extra-index-url https://pypi.nvidia.com -r "$REPO_DIR/requirements.txt"

# ---------- 4. editable 安装：IsaacLab + lab.flamingo ----------
echo "[4/5] 安装 IsaacLab 与 lab.flamingo（editable）..."
# IsaacLab：如果仓库旁有本地 checkout 就用本地的，否则从 git 固定 commit 安装
LOCAL_IL="$(dirname "$REPO_DIR")/IsaacLab"
if [ -d "$LOCAL_IL/source/isaaclab" ]; then
    echo "     使用本地 IsaacLab: $LOCAL_IL"
    $PIP -e "$LOCAL_IL/source/isaaclab"
    $PIP -e "$LOCAL_IL/source/isaaclab_assets"
    $PIP -e "$LOCAL_IL/source/isaaclab_mimic"
    $PIP -e "$LOCAL_IL/source/isaaclab_rl"
    $PIP -e "$LOCAL_IL/source/isaaclab_tasks"
else
    echo "     未找到本地 IsaacLab，从 git 固定 commit 安装"
    for pkg in isaaclab isaaclab_assets isaaclab_mimic isaaclab_rl isaaclab_tasks; do
        $PIP -e "$ISAACLAB_GIT#egg=$pkg&subdirectory=source/$pkg"
    done
fi
# lab.flamingo（本仓库自身）
$PIP -e "$REPO_DIR"

# ---------- 5. 验证 ----------
echo "[5/5] 验证安装 ..."
$PY -c "import isaacsim, torch; print('isaacsim OK | torch', torch.__version__)"
echo ""
echo "============================================================"
echo "环境就绪！启动方式："
echo "  cd $REPO_DIR"
echo "  ./run_train.sh          # 训练（headless）"
echo "  HEADLESS=0 ./run_train.sh --max_iterations 30   # 开窗口看"
echo "  资产注意：确认 lab/flamingo/assets/data/... 下的 USD 已解压"
echo "============================================================"
