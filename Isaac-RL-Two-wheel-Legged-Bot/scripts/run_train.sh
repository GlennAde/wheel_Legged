#!/usr/bin/env bash
# =============================================================================
# Flamingo 训练启动脚本（为本机调优：15GB 内存 / 8GB 显存 RTX 4060 Laptop）
#
# 用法（在仓库根目录执行）：
#   ./run_train.sh                                  # 默认 1024 envs, headless
#   NUM_ENVS=512 ./run_train.sh                     # 更保守（首次跑推荐 512）
#   HEADLESS=0 ./run_train.sh                       # 打开 Isaac Sim 窗口（可视化，见下方）
#   ./run_train.sh --max_iterations 10              # 追加其它参数
#   ./run_train.sh --task Isaac-Velocity-Flat-Flamingo-v1-srmppo
#
# 可视化（想看到机器人）：
#   HEADLESS=0 NUM_ENVS=64 ./run_train.sh --max_iterations 20
#   -> 会弹出 Isaac Sim 窗口显示机器人（带 RL 面板）。注意：
#      - 首次渲染要编译 shader，窗口可能过 1~3 分钟才出画面，属正常；
#      - GUI 模式更吃内存，envs 别开太大（64~256 即可）；
#      - 训练照常进行，机器人会边训练边乱动（初期会摔倒，正常）。
#
# 说明：
#   * 默认 --headless，训练时不需要打开 Isaac Sim 窗口，省内存省显存。
#   * 默认 num_envs=1024（仓库默认 4096 在本机内存/显存下会爆，见 部署与卡死排查.md）。
#   * 必须设置 PYTHONPATH=<仓库根>，否则 train.py 的 `from scripts.co_rl...` 会 ImportError。
#   * 输出同时写入 logs/train_<时间戳>.log，可用 tail -f 观察进度，避免误以为卡死。
# =============================================================================
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_PY="${VENV_PY:-$(dirname "$REPO_DIR")/env_isaaclab/bin/python}"

if [ ! -x "$VENV_PY" ]; then
    echo "[ERROR] 找不到 venv Python: $VENV_PY"
    echo "        请设置 VENV_PY 指向你的 env_isaaclab/bin/python，例如："
    echo "        VENV_PY=/path/to/env_isaaclab/bin/python ./run_train.sh"
    exit 1
fi

# ---- 可调参数（默认值针对本机，可按需覆盖） ----
TASK="${TASK:-Isaac-Velocity-Flat-Flamingo-v1-ppo}"
NUM_ENVS="${NUM_ENVS:-1024}"
ALGO="${ALGO:-ppo}"
NUM_POLICY_STACKS="${NUM_POLICY_STACKS:-2}"
NUM_CRITIC_STACKS="${NUM_CRITIC_STACKS:-2}"
# HEADLESS=1（默认，命令行训练） / HEADLESS=0（打开窗口可视化）
HEADLESS="${HEADLESS:-1}"
if [ "$HEADLESS" = "1" ]; then
    HEADLESS_ARGS="--headless"
    MODE_NOTE="headless（无窗口，省内存）"
else
    HEADLESS_ARGS=""
    MODE_NOTE="GUI 窗口模式（可视化）"
fi

mkdir -p "$REPO_DIR/logs"
LOG_FILE="$REPO_DIR/logs/train_$(date +%Y%m%d_%H%M%S).log"

echo "[INFO] venv python : $VENV_PY"
echo "[INFO] task        : $TASK"
echo "[INFO] num_envs    : $NUM_ENVS"
echo "[INFO] algo        : $ALGO"
echo "[INFO] 模式        : $MODE_NOTE"
echo "[INFO] 日志        : $LOG_FILE  (tail -f 观察进度)"
if [ "$HEADLESS" != "1" ]; then
    echo "[INFO] 窗口即将打开…… 首次渲染需编译 shader，画面可能要等 1~3 分钟，属正常现象。"
fi
echo "[INFO] 启动中…… 首次运行会编译 shader，可能看似'卡住'几分钟，属正常现象。"
echo "[INFO] 命令行      : $VENV_PY scripts/co_rl/train.py --task $TASK --algo $ALGO --num_envs $NUM_ENVS $HEADLESS_ARGS --num_policy_stacks $NUM_POLICY_STACKS --num_critic_stacks $NUM_CRITIC_STACKS $*"

cd "$REPO_DIR"
PYTHONPATH="$REPO_DIR" PYTHONUNBUFFERED=1 "$VENV_PY" scripts/co_rl/train.py \
    --task "$TASK" \
    --algo "$ALGO" \
    --num_envs "$NUM_ENVS" \
    $HEADLESS_ARGS \
    --num_policy_stacks "$NUM_POLICY_STACKS" \
    --num_critic_stacks "$NUM_CRITIC_STACKS" \
    "$@" 2>&1 | tee "$LOG_FILE"
