---
name: isaaclab-env
description: Use when working on the wheel-legged (双轮腿/轮腿) RL project under /home/glennade/wheel_legged — Isaac Lab v2.3 + Isaac Sim 4.5, uv venv env_isaaclab. Triggers: Isaac Lab, Isaac Sim, isaaclab, wheel_legged, 双轮腿, 轮腿, RL, 强化学习, train, play, list_envs, 训练, 环境. Also use when adding/editing tasks, configs, or extensions for this project.
---

# Isaac Lab 双轮腿项目环境

## 路径
- 工作区: `/home/glennade/wheel_legged`
- 源码:   `/home/glennade/wheel_legged/IsaacLab` (Isaac Lab v2.3.0)
- venv:   `/home/glennade/wheel_legged/env_isaaclab` (uv, Python 3.10.12)
- 解释器: `/home/glennade/wheel_legged/env_isaaclab/bin/python` (VSCode 已指向此路径)

## 依赖版本
- Isaac Sim 4.5.0 · isaaclab 0.47.2 · torch 2.7.0+cu128 · numpy 1.26.4
- gymnasium 1.2.0 · rsl-rl-lib 3.0.1 · skrl 2.1.0 · stable_baselines3 2.9.0
- setuptools 80.10.2 (已降级以提供 pkg_resources)

## 扩展结构 (均位于 IsaacLab/source/, 全部 editable 安装)
- `isaaclab`        核心 (0.47.2)
- `isaaclab_assets` 0.2.3
- `isaaclab_tasks`  0.11.6
- `isaaclab_rl`     0.4.4
- `isaaclab_mimic`  1.0.15

## 常用命令
- 激活: `source /home/glennade/wheel_legged/env_isaaclab/bin/activate`
- 列出环境: `python scripts/environments/list_envs.py` (已验证可跑通, 152 个任务)
- 训练: `python scripts/reinforcement_learning/rsl_rl/train.py --task <task> --headless`
- 回放: `python scripts/reinforcement_learning/rsl_rl/play.py --task <task>`
- 测试: `pytest`

## 注意事项
- 直接裸 `import isaaclab_tasks` 会报 `ModuleNotFoundError: No module named 'omni.physics'`,
  属正常: omni 模块须在脚本先启动 `SimulationApp`/`AppLauncher` 后才可导入。
- 重装核心 isaaclab 时, `flatdict==4.0.1` 构建需要 `pkg_resources`:
  先 `uv pip install "setuptools<81"`, 再
  `uv pip install -e . --no-build-isolation-package flatdict` (在 source/isaaclab 目录)。
