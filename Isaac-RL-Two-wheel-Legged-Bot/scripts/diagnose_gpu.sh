#!/usr/bin/env bash
# =============================================================================
# GPU / 环境自检脚本 —— 请在【你自己的终端】里运行（不要在 DSH 沙箱里跑）
#
#   cd /home/glennade/wheel_legged/Isaac-RL-Two-wheel-Legged-Bot
#   ./scripts/diagnose_gpu.sh
#
# 它会检查：显卡驱动、/dev/nvidia* 设备节点、PyTorch 能否用 CUDA、
# 内存/交换分区/磁盘空间。每一项给出 PASS / FAIL，FAIL 项就是卡死的最大嫌疑。
# =============================================================================
set -uo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
pass() { echo -e "${GREEN}[PASS]${NC} $1"; }
fail() { echo -e "${RED}[FAIL]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

REPO_DIR="$(cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")" && pwd)"
VENV_PY="${VENV_PY:-$(dirname "$REPO_DIR")/env_isaaclab/bin/python}"

echo "==================== 1. NVIDIA 驱动 ===================="
if command -v nvidia-smi >/dev/null 2>&1; then
    if nvidia-smi >/dev/null 2>&1; then
        nvidia-smi --query-gpu=name,driver_version,memory.total,memory.free --format=csv
        pass "nvidia-smi 正常"
    else
        fail "nvidia-smi 无法与驱动通信"
        echo "  -> 见排查文档『GPU 不通怎么办』"
    fi
else
    fail "找不到 nvidia-smi（驱动未装？）"
fi

echo ""
echo "==================== 2. /dev/nvidia* 设备节点 ===================="
if ls /dev/nvidiactl /dev/nvidia0 /dev/nvidia-uvm >/dev/null 2>&1; then
    ls -l /dev/nvidiactl /dev/nvidia0 /dev/nvidia-uvm 2>/dev/null
    pass "设备节点存在"
else
    fail "缺少 /dev/nvidiactl /dev/nvidia0 /dev/nvidia-uvm"
    echo "  -> 这是 CUDA 程序（Isaac Sim）启动即卡死/失败的常见原因，见排查文档"
fi

echo ""
echo "==================== 3. PyTorch + CUDA（用本项目的 venv） ===================="
if [ -x "$VENV_PY" ]; then
    "$VENV_PY" - <<'PYEOF' 2>&1 | tail -5
import torch
print("torch:", torch.__version__)
print("cuda available:", torch.cuda.is_available())
if torch.cuda.is_available():
    print("gpu:", torch.cuda.get_device_name(0))
PYEOF
    if "$VENV_PY" -c "import torch; exit(0 if torch.cuda.is_available() else 1)" >/dev/null 2>&1; then
        pass "PyTorch 可用 CUDA"
    else
        fail "PyTorch 检测不到 CUDA"
    fi
else
    fail "找不到 venv Python: $VENV_PY（可用 VENV_PY=... 指定）"
fi

echo ""
echo "==================== 4. 内存 / 交换分区 / 磁盘 ===================="
free -h | head -2
echo "--- swap ---"
swapon --show 2>/dev/null || echo "没有 swap！"
echo "--- 磁盘 ---"
df -h / /home/glennade/wheel_legged 2>/dev/null
echo "--- CPU ---"
echo "核心数: $(nproc)"

echo ""
echo "==================== 结论 ===================="
echo "如果第 1/2/3 项有任何 FAIL：先修 GPU（见 docs/部署与卡死排查.md），Isaac Sim 必然起不来或卡死。"
echo "如果全部 PASS：问题在内存/参数，按文档把 num_envs 降到 512~1024 并用 --headless 启动。"
