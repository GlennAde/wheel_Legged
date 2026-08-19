<!-- ═══════════════ Fork 增强说明（工作区结构 + 快速上手）═══════════════ -->

# Flamingo 双轮腿机器人（Isaac Lab）· 项目说明

> 本仓库是 Flamingo 双轮腿机器人（两轮 + 双腿，8 执行器）的仿真训练主仓库，
> 已适配 IsaacLab 2.3 并完成环境可复现化。上游：jaykorea/Isaac-RL-Two-wheel-Legged-Bot。

## 📦 完整工作区结构（克隆后的标准布局）

| 目录 | 是什么 | 是否提交 / 如何获取 |
|---|---|---|
| `env_isaaclab/` | Python 虚拟环境（Isaac Sim 4.5 + torch 2.7.0+cu128，约 20GB） | ❌ 不提交；`./setup_env.sh` 一键重建 |
| `IsaacLab/` | Isaac Lab 2.3 源码（editable 安装 5 子包，固定 commit） | ❌ 不提交；`setup_env.sh` 自动从 git 安装 |
| **本仓库** | lab.flamingo 任务包 + 训练/部署脚本 + 文档 | ✅ 就是本仓库 |
| `lab/flamingo/assets/data/` | 机器人 USD 资产（开源发布） | ❌ 不提交；`./download_assets.sh` 从上游获取 |

```
env_isaaclab (venv) ──editable──▶ IsaacLab ──editable──▶ 本仓库(lab.flamingo) ──▶ run_train.sh
```

## 🚀 快速上手（新机器 3 条命令）

```bash
git clone <本仓库>
cd Isaac-RL-Two-wheel-Legged-Bot

./download_assets.sh   # ① 机器人 USD 资产（git-lfs + 解压 zip，开源）
./setup_env.sh         # ② 一键创建环境（~20GB：torch cu128 + Isaac Sim 4.5 + IsaacLab）
./run_train.sh         # ③ 开始训练（默认 1024 envs, headless）
```

- 详细流程：`新人工作流指南.md` ｜ 排障：`部署与卡死排查.md` ｜ 技术栈：`技术栈.md`
- 环境损坏重建：`FRESH=1 ./setup_env.sh`（旧环境自动备份）
- ⚠️ 不要对现有 venv 执行 `uv pip sync -r requirements.txt`（会拆坏环境，详见排障文档）

---

---

# Isaac LAB for Flamingo

[![IsaacSim](https://img.shields.io/badge/IsaacSim-4.5-silver.svg)](https://docs.omniverse.nvidia.com/isaacsim/latest/overview.html)
[![IsaacLab](https://img.shields.io/badge/Lab-2.0.0-silver)](https://isaac-orbit.github.io/orbit/)
[![Python](https://img.shields.io/badge/python-3.10-blue.svg)](https://docs.python.org/3/whatsnew/3.10.html)
[![Linux platform](https://img.shields.io/badge/platform-linux--64-orange.svg)](https://releases.ubuntu.com/20.04/)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://pre-commit.com/)
[![License](https://img.shields.io/badge/license-MIT-yellow.svg)](https://opensource.org/license/mit)

## **✨ New Features - Updated 🚀**
✔️ **Flamingo rev.0.1.4**: Latest version of Flamingo added.  
✔️ **Flamingo Edu v1**: Flamingo Edu version added.  
✔️ **Stack Environment**: Observations can be stacked with arguments.  
✔️ **Constraint Manager**: [Constraints as Termination (CaT)](https://arxiv.org/abs/2403.18765) method implementation added.  
✔️ **CoRL**: Based on [rsl_rl](https://github.com/leggedrobotics/rsl_rl) library, off-policy algorithms are implemented on `off_policy_runner`.  

## Sim2Real - ZeroShot Transfer
<table>
    <td><img src="https://github.com/user-attachments/assets/bb14612c-85c2-43ce-a7df-8b09ee4d3f69" width="800" height="400"/></td>
</table>
<table>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/8f9f990d-e8e9-400a-82b2-1131ff73f891" width="385" height="170"/></td>
    <td><img src="https://github.com/user-attachments/assets/93c6b187-4680-435e-800a-9e6d3d570d13" width="385" height="170"/></td>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/9991ff73-5b3e-4d10-9b63-548197f18e54" width="385" height="170"/></td>
    <td><img src="https://github.com/user-attachments/assets/545fd258-1add-499a-8c62-520e113a951b" width="385" height="170"/></td>
  </tr>
</table>


## Isaac Lab Flamingo
<table>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/0037889b-bab7-4686-a9a5-46ea9bbe6ac2" width="385" height="240"/></td>
    <td><img src="https://github.com/user-attachments/assets/16d8d025-7e57-479a-80d4-9cfef2cf9b6b" width="385" height="240"/></td>
  </tr>
</table>

## Sim 2 Sim framework - Lab to MuJoCo
<table>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/edcc4077-e082-4fce-90a6-b10c94869aad" width="385" height="240"/></td>
    <td><img src="https://github.com/user-attachments/assets/df58b2db-00c6-4228-a953-eb605dee2797" width="385" height="240"/></td>
  </tr>
</table>

- Simulation to Simulation framework is available on sim2sim_onnx branch (Currently on migration update)
- You can simply inference trained policy (basically export as .onnx from isaac lab)

## Setup
- This repo is tested on Ubuntu 20.04, and I recommend you to install 'local install'
### 1. Install Isaac Sim
  ```
  https://isaac-sim.github.io/IsaacLab/main/source/setup/installation/binaries_installation.html
  ```
### 2. Install Isaac Lab
  ```
  https://github.com/isaac-sim/IsaacLab
  ```

### 3. Install lab.flamingo package
i. clone repository
   ```
   git clone https://github.com/jaykorea/Isaac-RL-Two-wheel-Legged-Bot
   ```
ii. install lab.flamingo pip package by running below command
   - run it on 'lab.flamingo' root path
   ```
   conda activate env_isaaclab # change to you conda env
   pip install -e .
   ```
iii. Unzip assets(usd asset) on folder
   - Since git does not correctly upload '.usd' file, you should manually unzip the usd files on assests folder
   ```
    path example: lab/flamingo/assets/data/Robots/Flamingo/flamingo_rev01_4_1/
   ```

## Launch script
### Train flamingo
  - run it on 'lab.flamingo' root path
  ```
    python scripts/co_rl/train.py --task {task name} --algo ppo --num_envs 4096 --headless --num_policy_stacks {stack number on policy obs} --num_critic_stacks {stack number on critic obs}
  ```
### Train example - track velocity
  ```
    python scripts/co_rl/train.py --task Isaac-Velocity-Flat-Flamingo-v1-ppo --algo ppo --num_envs 4096 --headless --num_policy_stacks 2 --num_critic_stacks 2
  ```
### play flamingo
  - run it on 'lab.flamingo' root path
  ```
    python scripts/co_rl/play.py --task {task name} --algo ppo --num_envs 64 --num_policy_stacks {stack number on policy obs} --num_critic_stacks {stack number on critic obs} --load_run {folder name} --plot False
  ```
### play example - track velocity
  ```
    python scripts/co_rl/play.py --task Isaac-Velocity-Flat-Flamingo-Play-v1-ppo --algo ppo --num_envs 64 --num_policy_stacks {stack number on policy obs} --num_critic_stacks {stack number on critic obs} --load_run 2025-03-16_17-09-35 --plot False
  ```
