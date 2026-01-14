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

## 问题

每天，你都在解决相同的问题。修复相同的错误。重新发现相同的模式。

**你的 AI 助手在会话之间会遗忘一切。**

## 解决方案

Auto-Evolution 赋予你的 AI 助手**记忆**——持久的、学习的、进化的记忆。

```
之前:  你 → Agent → 输出 → (遗忘)
之后:  你 → Agent → 输出 → 记忆 → 学习 → 进化
```

---

## ✨ 核心特性

| | 特性 | 描述 |
|---|------|------|
| 🧠 | **三层记忆** | 情景 → 语义 → 程序性知识，灵感源自人类认知 |
| ⚡ | **模式检测** | 自动识别重复出现的工作流和解决方案 |
| 📊 | **可视化仪表盘** | 实时展示 Agent 的学习进度 |
| 🔄 | **反思循环** | 从成功和失败中学习 |
| 🎯 | **质量门控** | 只有验证过的知识才会被提升 |
| 🌍 | **社区共享** | 跨项目分享和复用模式 |

---

## 🚀 快速开始

### 一键安装

```bash
curl -fsSL https://raw.githubusercontent.com/ZhanlinCui/Auto-Evolution-Agent-Skills/main/install.sh | bash -s -- --with-hooks
```

### 接下来会发生什么

1. **正常工作** — Auto-Evolution 在后台静默捕获
2. **模式浮现** — 系统检测重复的工作流和解决方案
3. **知识进化** — 验证过的模式成为可复用技能
4. **Agent 进步** — 你的助手随时间变得更智能

---

## 🧠 三层记忆系统

灵感源自认知科学，Auto-Evolution 实现了分层记忆系统：

```
┌────────────────────────────────────────────────────────────────┐
│  情景记忆                                    TTL: 7 天         │
│  原始事件: "使用了 layout.md" "修复了错误 X"                    │
└────────────────────────────────────────────────────────────────┘
                              ↓ 抽象化
┌────────────────────────────────────────────────────────────────┐
│  语义记忆                                    TTL: 30 天        │
│  模式: "TypeScript 错误遵循模式 X"                              │
└────────────────────────────────────────────────────────────────┘
                              ↓ 验证
┌────────────────────────────────────────────────────────────────┐
│  程序记忆                                    永久               │
│  技能: 可在未来会话中直接使用的知识                              │
└────────────────────────────────────────────────────────────────┘
```

---

## 📊 可视化仪表盘

实时查看你的 Agent 进化过程：

<p align="center">
  <img src="docs/dashboard-preview.png" alt="仪表盘预览" width="800" />
</p>

- 📈 会话统计和趋势
- 🧠 记忆层可视化
- ⚡ 待提升的检测模式
- 💡 基于证据的改进建议
- 📊 技能使用热力图

**体验:** `open reports/dashboard.html`

---

## 🏗️ 架构

```
evolution/
├── SKILL.md              # 入口
├── config.json           # 配置
│
├── memory/               # 🧠 三层记忆
│   ├── episodes.jsonl    # 原始事件
│   ├── patterns.json     # 检测到的模式
│   └── drafts/           # 技能候选
│
├── hooks/                # 🪝 事件捕获
│   ├── capture.sh        # 工具前后钩子
│   └── reflect.sh        # 会话结束分析
│
├── reports/              # 📊 可视化
│   └── dashboard.html    # 可视化仪表盘
│
└── community/            # 🌍 共享知识
```

---

## 📖 使用方法

### 自动模式

启用 hooks 后，一切自动发生：

- ✅ 技能使用被追踪
- ✅ 错误被捕获（带上下文）
- ✅ 模式被检测并起草
- ✅ 会话报告自动生成

### 手动命令

| 命令 | 功能 |
|------|------|
| `/retrospective` | 生成带洞察的会话回顾 |
| `/evolve` | 将检测到的模式提升为技能 |
| `/dashboard` | 打开可视化仪表盘 |

### 示例会话

```
你: 修复这个 TypeScript 错误
Agent: [使用特定模式修复错误]

你: /retrospective
Agent: 我注意到你已经修复了 4 次类似的 TypeScript 错误。
       检测到模式: "API 响应的类型守卫"
       要我把这个保存为可复用技能吗？

你: 好的，/evolve
Agent: 已创建: community/yourhandle-api-type-guard.md
       这个模式现在可以在未来的会话中使用了。
```

---

## ⚙️ 配置

所有设置集中在一个文件 — `config.json`：

```json
{
  "memory": {
    "episodic_ttl_days": 7,
    "semantic_ttl_days": 30,
    "pattern_threshold": 3
  },
  "evolution": {
    "auto_draft_on_error": true,
    "auto_pattern_detection": true
  }
}
```

---

## 🤝 贡献

### 分享你的模式

1. 创建 `community/{你的ID}-{模式名}.md`
2. 使用 `templates/` 中的模板
3. 提交 PR

### 质量指南

- ✅ 解决真实、可重复的问题
- ✅ 包含"Use when..."触发场景
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

## 📄 许可证

MIT License — 详见 [LICENSE](LICENSE)。

---

<p align="center">
  <strong>让你的 Agent 学习，让它进化。</strong>
</p>

<p align="center">
  <a href="https://github.com/ZhanlinCui/Auto-Evolution-Agent-Skills">⭐ Star 这个仓库</a> •
  <a href="https://github.com/ZhanlinCui/Auto-Evolution-Agent-Skills/issues">报告 Bug</a> •
  <a href="https://github.com/ZhanlinCui/Auto-Evolution-Agent-Skills/issues">功能请求</a>
</p>
