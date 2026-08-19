#!/usr/bin/env bash
# =============================================================================
# Flamingo 播放（评估已训练策略）启动脚本
#
# 用法（在仓库根目录执行）：
#   ./scripts/run_play.sh --load_run 2025-03-16_17-09-35
#   NUM_ENVS=128 ./scripts/run_play.sh --load_run <run文件夹名>
#   ./scripts/run_play.sh --load_run <run文件夹名> --plot True
#   HEADLESS=0 ./scripts/run_play.sh --load_run <run文件夹名>   # 打开窗口看机器人跑
#
# 说明：
#   * --load_run 填 logs/co_rl/<experiment>/ppo/ 下的文件夹名
#   * 默认 headless；HEADLESS=0 打开窗口看画面（更吃内存，envs 建议 ≤64）
# =============================================================================
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")" && pwd)"
VENV_PY="${VENV_PY:-$(dirname "$REPO_DIR")/env_isaaclab/bin/python}"

if [ ! -x "$VENV_PY" ]; then
    echo "[ERROR] 找不到 venv Python: $VENV_PY"
    exit 1
fi

TASK="${TASK:-Isaac-Velocity-Flat-Flamingo-Play-v1-ppo}"
NUM_ENVS="${NUM_ENVS:-64}"
ALGO="${ALGO:-ppo}"
NUM_POLICY_STACKS="${NUM_POLICY_STACKS:-2}"
NUM_CRITIC_STACKS="${NUM_CRITIC_STACKS:-2}"
HEADLESS="${HEADLESS:-1}"
if [ "$HEADLESS" = "1" ]; then
    HEADLESS_ARGS="--headless"
else
    HEADLESS_ARGS=""
fi

if [ "$#" -eq 0 ]; then
    echo "[ERROR] 请至少传 --load_run <run文件夹名>"
    echo "        例如: ./scripts/run_play.sh --load_run 2025-03-16_17-09-35"
    exit 1
fi

cd "$REPO_DIR"
PYTHONPATH="$REPO_DIR" PYTHONUNBUFFERED=1 "$VENV_PY" scripts/co_rl/play.py \
    --task "$TASK" \
    --algo "$ALGO" \
    --num_envs "$NUM_ENVS" \
    $HEADLESS_ARGS \
    --num_policy_stacks "$NUM_POLICY_STACKS" \
    --num_critic_stacks "$NUM_CRITIC_STACKS" \
    "$@"
