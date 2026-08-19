#!/usr/bin/env bash
# =============================================================================
# 下载 Flamingo 机器人 USD 资产（上游 jaykorea 仓库，git-lfs）
#
# 用法：./scripts/download_assets.sh   （在仓库根目录执行）
#
# 说明：机器人资产（*.usd）体积大且是开源发布，不随本项目仓库提交，
#       新人 clone 后先跑本脚本获取资产，再跑 setup_env.sh。
# =============================================================================
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")" && pwd)"
UPSTREAM="https://github.com/jaykorea/Isaac-RL-Two-wheel-Legged-Bot.git"
DEST="$REPO_DIR/lab/flamingo/assets/data"

echo "[INFO] 从上游拉取资产: $UPSTREAM"
echo "[INFO] 目标目录: $DEST"
mkdir -p "$DEST"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

git clone --depth 1 "$UPSTREAM" "$TMP/upstream"

# 若装有 git-lfs，拉取 LFS 资产；否则提示
if command -v git-lfs >/dev/null 2>&1; then
    echo "[INFO] 拉取 git-lfs 资产（*.usd 等）..."
    (cd "$TMP/upstream" && git lfs pull) || echo "[WARN] git lfs pull 失败，资产可能不完整"
else
    echo "[WARN] 未安装 git-lfs（sudo apt install git-lfs）。USD 资产可能只是指针文件。"
fi

echo "[INFO] 拷贝资产到 $DEST ..."
# 只拷贝 data 下的资产；跳过上游的 configuration 缓存等
if [ -d "$TMP/upstream/lab/flamingo/assets/data" ]; then
    cp -rn "$TMP/upstream/lab/flamingo/assets/data/." "$DEST/" 2>/dev/null || true
else
    echo "[ERROR] 上游仓库里没有 assets/data，请检查上游仓库结构"
    exit 1
fi

# 解压 assets 下的 zip（上游把 usd 打包在 zip 里，git 不直接存 usd）
echo "[INFO] 解压 *.zip ..."
find "$DEST" -name "*.zip" -print0 2>/dev/null | while IFS= read -r -d '' z; do
    d="$(dirname "$z")"
    echo "  解压: $z -> $d"
    unzip -o -q "$z" -d "$d" 2>/dev/null || echo "  [WARN] 解压失败: $z"
done

echo ""
echo "============================================================"
echo "资产就绪！检查示例（应存在）："
ls -la "$DEST/Robots/Flamingo/flamingo_rev01_5_2/flamingo_rev01_5_2_merge_joints.usd" 2>/dev/null \
    || echo "  ⚠️ 未找到 flamingo_rev01_5_2 usd，请检查上游资产结构"
echo "下一步：./scripts/setup_env.sh"
echo "============================================================"
