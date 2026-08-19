#!/usr/bin/env python3
"""
在线自动清理 requirements.txt 中无法解析的包（如 ROS 2 生态遗留）。

用法（在仓库根目录）：
    python3 scripts/clean_requirements.py

原理：反复运行 `uv pip compile` 在线解析依赖，每次把 uv 报出的
"no version of X" / "X was not found" 包从 requirements.txt 剔除，直到解析通过。
（只改 requirements.txt；requirements-full.txt 由它重新生成。）

注意：需要联网（PyPI + NVIDIA 源）。
"""
import re
import subprocess
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
REQ = REPO / "requirements.txt"
FULL = REPO / "requirements-full.txt"

if not REQ.exists():
    print(f"找不到 {REQ}")
    sys.exit(1)

# 不验证的 NVIDIA 源包前缀（它们在线能装，只是离线/特殊解析时可能误报）
SKIP_PREFIX = ("isaacsim", "omni-", "omniverse", "cuda-toolkit")

removed = []
for i in range(1, 100):
    r = subprocess.run(
        ["uv", "pip", "compile", "--extra-index-url", "https://pypi.nvidia.com",
         str(REQ)],
        capture_output=True, text=True, cwd=REPO,
    )
    out = r.stdout + r.stderr
    if r.returncode == 0:
        print(f"\n✅ 解析通过！共剔除 {len(removed)} 个包")
        break
    m = re.search(r"no version of ([\w.-]+)", out) or re.search(r"([\w.-]+) was not found", out)
    if not m:
        print("\n❌ 无法识别的错误，请人工处理，以下是报错尾部：")
        print(out[-2000:])
        sys.exit(1)
    pkg = m.group(1)
    if pkg.startswith(SKIP_PREFIX):
        print(f"[{i}] {pkg} 是 NVIDIA 源包，跳过（保留）")
        continue
    print(f"[{i}] 剔除: {pkg}")
    removed.append(pkg)
    lines = [l for l in REQ.read_text().split("\n")
             if not (l.startswith(pkg + "==") or l.startswith(pkg + " @"))]
    REQ.write_text("\n".join(lines))
else:
    print("\n达到迭代上限，仍有未解决项")
    sys.exit(1)

# 用清理后的 requirements.txt 重建 requirements-full.txt
base = [l for l in REQ.read_text().split("\n") if l and not l.startswith("#")]
torch_lines = ["torch==2.7.0+cu128", "torchvision==0.22.0+cu128"]
editable_lines = [
    "-e git+https://github.com/isaac-sim/IsaacLab.git@3c6e67bb5c7ada942a6d1884ab69338f57596f77#egg=isaaclab&subdirectory=source/isaaclab",
    "-e git+https://github.com/isaac-sim/IsaacLab.git@3c6e67bb5c7ada942a6d1884ab69338f57596f77#egg=isaaclab_assets&subdirectory=source/isaaclab_assets",
    "-e git+https://github.com/isaac-sim/IsaacLab.git@3c6e67bb5c7ada942a6d1884ab69338f57596f77#egg=isaaclab_mimic&subdirectory=source/isaaclab_mimic",
    "-e git+https://github.com/isaac-sim/IsaacLab.git@3c6e67bb5c7ada942a6d1884ab69338f57596f77#egg=isaaclab_rl&subdirectory=source/isaaclab_rl",
    "-e git+https://github.com/isaac-sim/IsaacLab.git@3c6e67bb5c7ada942a6d1884ab69338f57596f77#egg=isaaclab_tasks&subdirectory=source/isaaclab_tasks",
    "-e git+https://github.com/jaykorea/Isaac-RL-Two-wheel-Legged-Bot.git@d922cce9e07a8877c37e12b2cb39dfdcf34b9d40#egg=lab.flamingo",
]
header = [
    "# ============================================================",
    "# 完整环境清单（含 torch 与 editable 包）—— 供 uv pip install/sync 使用",
    "# 安装命令：",
    "#   uv pip install --extra-index-url https://download.pytorch.org/whl/cu128 \\",
    "#                --extra-index-url https://pypi.nvidia.com -r requirements-full.txt",
    "# 注意：ROS 2 包已剔除；含固定 commit 的 git 依赖，首次会 clone。",
    "# ============================================================",
]
FULL.write_text("\n".join(header + base + torch_lines + editable_lines) + "\n")
print(f"已重建 requirements-full.txt（{len(base)} 固定包 + 2 torch + 6 editable）")
