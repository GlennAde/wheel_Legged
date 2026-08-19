# wheel_legged —— Flamingo 双轮腿机器人项目工作区

> 本目录是 Flamingo 双轮腿机器人（两轮 + 双腿，8 执行器）的仿真训练完整工作区：
> Isaac Sim 4.5（物理引擎）+ Isaac Lab 2.3（RL 框架）+ lab.flamingo（机器人任务包）。

---

## 目录说明

| 目录 | 大小 | 是什么 | 能否删除 / 如何重建 |
|---|---|---|---|
| `env_isaaclab/` | ~20G | **Python 虚拟环境**（uv 创建，Python 3.10）：Isaac Sim 4.5 pip 全家 + torch 2.7.0+cu128 + 全部依赖 | 可删。重建：`cd Isaac-RL-Two-wheel-Legged-Bot && ./scripts/setup_env.sh`（一键） |
| `IsaacLab/` | ~166M | **Isaac Lab 2.3.0 源码**（editable 安装：isaaclab / isaaclab_tasks / isaaclab_rl / isaaclab_assets / isaaclab_mimic，固定 commit `3c6e67bb`） | 可删。`scripts/setup_env.sh` 会自动从 git 固定 commit 重建（保留本地可加速安装） |
| `Isaac-RL-Two-wheel-Legged-Bot/` | ~2.2G | **Flamingo 机器人主仓库**（lab.flamingo 包 + USD 资产）：训练 / 播放 / 导出 ONNX / 一键脚本 / 文档全在这里 | **主要工作目录，不要删**（git 仓库，资产已解压） |

---

## 三者关系（架构）

```
env_isaaclab (venv：isaacsim 4.5 + torch 2.7.0+cu128)
   │  editable 安装（.pth 指向本机绝对路径）
   ▼
IsaacLab (isaaclab 2.3.0 五个子包)
   │  editable 安装
   ▼
Isaac-RL-Two-wheel-Legged-Bot (lab.flamingo 1.2.0)
   │
   ▼
训练入口：Isaac-RL-Two-wheel-Legged-Bot/scripts/run_train.sh
```

- **任务/配置/奖励**：`Isaac-RL-Two-wheel-Legged-Bot/lab/flamingo/tasks/`
- **机器人资产（USD）**：`Isaac-RL-Two-wheel-Legged-Bot/lab/flamingo/assets/data/`
- **⚠️ 兼容性**：仓库按 IsaacLab 2.0 编写，当前环境是 2.3（已打补丁跑通）。
  升级 IsaacLab 前先确认仓库兼容，别轻易动。

---

## 日常命令速查

```bash
# 全部在仓库根目录执行（脚本自动使用 env_isaaclab 的 python 并设置 PYTHONPATH）
cd /home/glennade/wheel_legged/Isaac-RL-Two-wheel-Legged-Bot

./scripts/setup_env.sh                          # 重建/修复环境（新人、换机器时用）
./scripts/diagnose_gpu.sh                       # GPU 自检（在自己终端跑）
./scripts/run_train.sh                          # 训练（默认 1024 envs, headless）
NUM_ENVS=512 ./scripts/run_train.sh             # 更省内存
HEADLESS=0 ./scripts/run_train.sh --max_iterations 30   # 打开窗口看可视化
./scripts/run_train.sh --video --max_iterations 200     # 录训练视频
./scripts/run_play.sh --load_run <时间戳>        # 评估 + 自动导出 ONNX
```

训练日志 / 检查点 / 导出模型：
`Isaac-RL-Two-wheel-Legged-Bot/logs/co_rl/Flamingo_Flat_Stand_Drive/ppo/<时间戳>/`

---

## 备份 / 迁移须知

| 内容 | 建议 |
|---|---|
| `env_isaaclab/` | **不要备份/打包**（20G 且 .pth 写死本机路径）；迁移 = 重跑 `scripts/setup_env.sh` |
| `IsaacLab/` | 不用备份，可从 git 重建；本地保留只为装得快 |
| `Isaac-RL-Two-wheel-Legged-Bot/` | **要提交/备份**（git 仓库；注意 `.gitignore` 忽略了 USD 资产和 logs，资产需另行备份） |
| 训练产物 `logs/` | 检查点/导出模型值得备份；单次 2~3G |

---

## 文档索引

| 文档 | 位置 |
|---|---|
| 新人工作流指南（从零到部署的完整流程） | `Isaac-RL-Two-wheel-Legged-Bot/docs/新人工作流指南.md` |
| 部署与 Isaac Sim 卡死排查 | `Isaac-RL-Two-wheel-Legged-Bot/docs/部署与卡死排查.md` |
| 技术栈 | `Isaac-RL-Two-wheel-Legged-Bot/docs/技术栈.md` |
| 仓库自带 README（原始说明） | `Isaac-RL-Two-wheel-Legged-Bot/README.md` |
| 上游原始说明（jaykorea） | `Isaac-RL-Two-wheel-Legged-Bot/docs/upstream-README.md` |

---

## 常见误区

- ❌ 在 `wheel_legged` 根目录直接 `python xxx.py` —— 用仓库里的 `scripts/run_*.sh`
- ❌ 把 `env_isaaclab/`、`IsaacLab/` 提交进 git —— 它们不是项目代码，用脚本重建
- ❌ 训练不 headless —— 15GB 内存撑不住 GUI + 大批量并行环境（看可视化除外）
