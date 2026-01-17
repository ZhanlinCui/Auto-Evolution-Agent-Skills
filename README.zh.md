<p align="center">
  <img src="docs/logo.svg" alt="Auto-Evolution" width="120" />
</p>

<h1 align="center">Auto-Evolution</h1>

<p align="center">
  <strong>记忆驱动的 AI Agent 技能自进化系统</strong>
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT"></a>
  <a href="#"><img src="https://img.shields.io/badge/Version-2.0.0-blue.svg" alt="Version"></a>
  <a href="#"><img src="https://img.shields.io/badge/Claude_Code-兼容-8A2BE2.svg" alt="Claude Code"></a>
  <a href="#"><img src="https://img.shields.io/badge/PRs-Welcome-brightgreen.svg" alt="PRs Welcome"></a>
</p>

<p align="center">
  <a href="README.md">English</a> •
  <a href="README.zh.md">中文</a>
</p>

---

## 💡 故事

> *"这个错误我这周已经修了三次了。为什么我的 AI 助手就是记不住？"*

每个开发者都经历过这种情况。你花了 30 分钟调试一个问题，终于修好了，然后继续工作。两天后，你又遇到了同样的问题——而你的 AI 助手已经完全忘记了你是怎么解决的。

**你的 AI 很聪明，但它没有记忆。**

Auto-Evolution 改变了这一点。它赋予你的 AI 助手持久的记忆，从每次交互中学习，检测你工作中的模式，并随着时间推移进化成更智能的助手。

```
第1周:  你修复 TypeError #1 → Agent 遗忘
第2周:  你修复 TypeError #2 → Agent 遗忘
第3周:  你修复 TypeError #3 → Agent 遗忘

使用 Auto-Evolution:
第1周:  你修复 TypeError #1 → Agent 记住
第2周:  你修复 TypeError #2 → Agent 发现模式
第3周:  遇到 TypeError #3 → Agent: "我见过这个问题，解决方法是..."
```

---

## 🎯 解决的问题

| 问题 | 没有 Auto-Evolution | 有 Auto-Evolution |
|------|---------------------|-------------------|
| **重复错误** | 多次修复同一个 bug | Agent 从首次修复中学习 |
| **知识丢失** | 解决方案在会话后消失 | 模式跨会话持久保存 |
| **无个性化** | 每次都是通用回复 | Agent 适应你的工作流 |
| **手动文档** | 你自己记录所有内容 | 自动生成技能草稿 |
| **盲区** | 不知道什么方法有效 | 仪表盘展示效果数据 |

---

## ✨ 核心特性

<table>
<tr>
<td width="50%">

### 🧠 三层记忆
灵感源自人类认知：
- **情景记忆**: 原始事件 (7天)
- **语义记忆**: 抽象模式 (30天)
- **程序记忆**: 技能 (永久)

</td>
<td width="50%">

### ⚡ 模式检测
自动识别：
- 重复的工作流
- 常见错误解决方案
- 高频使用的技巧

</td>
</tr>
<tr>
<td width="50%">

### 📊 可视化仪表盘
实时展示：
- 技能使用热力图
- 检测到的模式
- 进化进度

</td>
<td width="50%">

### 🔄 质量门控
只有验证过的知识才会被提升：
- 3+ 次出现 → 检测到
- 验证通过 → 批准
- 持续使用 → 永久技能

</td>
</tr>
</table>

---

## 📊 可视化仪表盘

实时查看你的 Agent 进化过程：

<p align="center">
  <img src="docs/dashboard-preview.png" alt="仪表盘预览" width="800" />
</p>

---

## 🚀 快速开始

### 第一步：安装（30秒）

```bash
curl -fsSL https://raw.githubusercontent.com/ZhanlinCui/Auto-Evolution-Agent-Skills/main/install.sh | bash -s -- --with-hooks
```

<details>
<summary>📦 备选：手动安装</summary>

```bash
# 克隆仓库
git clone https://github.com/ZhanlinCui/Auto-Evolution-Agent-Skills.git

# 复制到你的项目
cp -r Auto-Evolution-Agent-Skills/skills/evolution your-project/.claude/skills/

# 添加执行权限
chmod +x your-project/.claude/skills/evolution/hooks/*.sh
```

</details>

### 第二步：配置 Hooks

添加到你的 `.claude/settings.json`：

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Read|Write|Edit|Bash",
        "hooks": [{"type": "command", "command": "bash .claude/skills/evolution/hooks/capture.sh \"$TOOL_NAME\" \"$TOOL_INPUT\""}]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{"type": "command", "command": "bash .claude/skills/evolution/hooks/capture.sh post-bash \"$TOOL_OUTPUT\" \"$EXIT_CODE\""}]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [{"type": "command", "command": "bash .claude/skills/evolution/hooks/reflect.sh"}]
      }
    ]
  }
}
```

### 第三步：正常工作

就这样！像平常一样使用 Claude Code。Auto-Evolution 在后台静默运行。

### 第四步：观察进化

```bash
# 打开仪表盘
open .claude/skills/evolution/reports/dashboard.html
```

---

## 📖 使用指南

### 自动模式（默认）

安装后，一切自动发生：

| 发生了什么 | 触发时机 | 结果 |
|-----------|---------|------|
| 技能使用被追踪 | 你读取任何 `.md` 技能文件 | 记录到情景记忆 |
| 错误被捕获 | Bash 命令失败 | 错误 + 上下文被保存 |
| 模式被检测 | 同一动作 3+ 次 | 创建模式假设 |
| 洞察被生成 | 会话结束 | 创建草稿 + 建议 |

### 手动命令

| 命令 | 功能 | 示例 |
|------|------|------|
| `/retrospective` | 生成会话回顾 | "今天我学到了什么？" |
| `/evolve` | 将模式提升为技能 | "把这个修复保存为技能" |
| `/dashboard` | 打开可视化仪表盘 | "展示我的进化" |

### 示例会话

```
你: 修复这个 TypeScript 错误："Object is possibly undefined"

Agent: [使用可选链修复]

--- 3 次类似修复后 ---

Agent: 💡 我注意到你已经用可选链修复了 3 次 "possibly undefined" 错误。
       要我把这个保存为可复用的模式吗？

你: 好的，创建一个技能

Agent: ✅ 已创建: community/typescript-optional-chaining.md
       下次我会立即建议这个模式。
```

---

## 🧠 工作原理

### 进化循环

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                  │
│    📝 捕获              🔍 分析              🚀 进化             │
│    ──────              ──────              ──────               │
│    工具使用     →      发现模式      →     创建技能             │
│    错误         →      检测重复      →     提升草稿             │
│    命令         →      评估成功率    →     淘汰失败             │
│                                                                  │
│                         🧠 记忆                                  │
│                         ──────                                   │
│                  情景 → 语义 → 程序                              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 三层记忆

| 层级 | 存储内容 | 保留时间 | 示例 |
|------|---------|---------|------|
| **情景** | 原始事件 | 7 天 | "14:32 使用了 layout.md" |
| **语义** | 模式 | 30 天 | "Grid 布局需要 Flow + Sizing" |
| **程序** | 技能 | 永久 | `responsive-grid-pattern.md` |

### 质量门控

知识必须证明自己才能成为永久知识：

```
[检测到]  ──3+次出现──▶  [草稿]  ──验证通过──▶  [批准]  ──持续使用──▶  [技能]
    │                      │                      │                     │
  发现模式              自动生成文档           人工/AI验证            永久知识
```

---

## ⚙️ 配置

所有设置在 `evolution/config.json`：

```json
{
  "memory": {
    "episodic_ttl_days": 7,      // 原始事件保留时间
    "semantic_ttl_days": 30,     // 模式保留时间
    "pattern_threshold": 3       // 检测模式所需的出现次数
  },
  "evolution": {
    "auto_draft_on_error": true,        // 错误时创建草稿
    "auto_pattern_detection": true,     // 自动检测模式
    "require_validation": true          // 提升前需要验证
  }
}
```

---

## 📁 项目结构

```
.claude/skills/evolution/
│
├── 📄 SKILL.md                 # 入口和文档
├── ⚙️ config.json              # 所有配置
│
├── 🧠 memory/                  # 三层记忆系统
│   ├── episodes.jsonl          # 第1层：原始事件
│   ├── patterns.json           # 第2层：检测到的模式
│   └── drafts/                 # 第3层：技能候选
│
├── 🪝 hooks/                   # 事件捕获系统
│   ├── capture.sh              # 工具前后钩子
│   ├── reflect.sh              # 会话结束分析
│   └── lib.sh                  # 共享工具
│
├── 📊 reports/                 # 可视化和报告
│   ├── dashboard.html          # 可视化仪表盘
│   ├── improvements.md         # 改进建议
│   └── sessions/               # 会话报告
│
├── 📝 templates/               # 技能模板
│   ├── skill.md                # 通用技能模板
│   └── error.md                # 错误解决模板
│
└── 🌍 community/               # 你贡献的技能
    └── README.md               # 贡献指南
```

---

## 🤝 贡献

### 分享你的模式

发现了有用的模式？与社区分享：

1. 创建 `community/{你的ID}-{模式名}.md`
2. 使用 `templates/` 中的模板
3. 提交 PR

### 质量清单

- ✅ 解决真实、可重复的问题
- ✅ 包含触发场景（"Use when..."）
- ✅ 有经过测试的具体示例
- ✅ 无项目特定的硬编码值

---

## 🗺️ 路线图

- [x] **v2.0** — 三层记忆系统
- [x] **v2.0** — 可视化仪表盘
- [x] **v2.0** — 模式检测
- [ ] **v2.1** — 跨项目知识同步
- [ ] **v2.2** — LLM-as-judge 验证
- [ ] **v2.3** — 社区知识联邦

---

## ❓ 常见问题

<details>
<summary><strong>支持其他 AI 助手吗？</strong></summary>

目前针对 Claude Code 优化，但架构设计为可移植的。欢迎为其他平台贡献！

</details>

<details>
<summary><strong>数据存储在哪里？</strong></summary>

所有数据都保存在项目的 `.claude/skills/evolution/memory/` 目录中。没有数据被发送到外部。

</details>

<details>
<summary><strong>会增加多少开销？</strong></summary>

极小。Hooks 是追加到 JSONL 文件的 shell 脚本。模式检测只在会话结束时运行。

</details>

<details>
<summary><strong>可以临时禁用吗？</strong></summary>

可以，只需从 `.claude/settings.json` 中移除 hooks。你的记忆数据会被保留。

</details>

---

## 📄 许可证

MIT License — 详见 [LICENSE](LICENSE)。

---

<p align="center">
  <strong>停止重复解决问题，开始进化。</strong>
</p>

<p align="center">
  <a href="https://github.com/ZhanlinCui/Auto-Evolution-Agent-Skills">⭐ Star</a> •
  <a href="https://github.com/ZhanlinCui/Auto-Evolution-Agent-Skills/issues">Issues</a> •
  <a href="https://github.com/ZhanlinCui/Auto-Evolution-Agent-Skills/pulls">PRs</a>
</p>
