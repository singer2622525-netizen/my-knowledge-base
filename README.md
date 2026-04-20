# 知识库导航

**用途**: 详细知识资产，供深入查阅和参考
**最后更新**: 2026年1月

---

## 🔗 与 Cursor Rules 的关系

本知识库与 Cursor 全局 Rules 配合使用：

| 内容类型 | Cursor Rules | 本知识库 |
|---------|-------------|---------|
| 反模式提醒 | ✅ 精炼版（每次对话自动加载） | 详细分析（需要时查阅） |
| 项目检查清单 | ✅ 核心检查项 | 完整版本 |
| 经验教训 | ✅ 摘要版 | 完整案例分析 |
| 环境配置 | ✅ 快速参考 | 详细配置文档 |

**使用原则**：
- **日常编程**：Cursor Rules 自动提供提醒和规则
- **深入了解**：查阅本知识库获取详细信息
- **新增知识**：先更新 Rules 摘要，再补充知识库详情

---

## 📋 知识库结构

```
03-knowledge-base/
├── failure-cases/             # 失败案例库（详细分析）
│   └── next-ai-draw-io/      # Next-AI-Draw-IO失败案例
├── success-cases/             # 成功案例库
├── decision-frameworks/       # 决策框架（完整版表格）
├── patterns/                  # 模式库（已整合到Rules，保留详情）
│   └── anti-patterns/        # 反模式详细分析
├── technical-guides/          # 技术指南
└── tools-and-scripts/         # 工具脚本库
```

---

## 🎯 知识分类

### 1. 失败案例库（failure-cases/）

**用途**: 系统化收集和分析失败案例，提炼经验教训

**案例列表**:

#### Next-AI-Draw-IO Web部署失败

**案例位置**: `failure-cases/next-ai-draw-io/`

**案例文档**:
- [案例摘要](failure-cases/next-ai-draw-io/01-案例摘要.md) - 1页纸总结
- [详细分析](failure-cases/next-ai-draw-io/02-详细分析.md) - 完整分析报告
- [决策复盘](failure-cases/next-ai-draw-io/03-决策复盘.md) - 关键决策复盘
- [技术债务清单](failure-cases/next-ai-draw-io/04-技术债务清单.md) - 技术债务分析
- [预防措施](failure-cases/next-ai-draw-io/05-预防措施.md) - 未来预防措施

**核心教训**:
- 需求分析要深入
- 技术选型要有依据
- 成本评估要全面

**案例价值**: ⭐⭐⭐⭐⭐ 高价值

**详细索引**: [失败案例库索引](failure-cases/README.md)

---

### 2. 反模式卡片（patterns/anti-patterns/）

**用途**: 识别和避免常见的反模式

**反模式列表**:

1. [演示系统生产化](patterns/anti-patterns/演示系统生产化.md)
2. [过度工程化](patterns/anti-patterns/过度工程化.md)
3. [忽略使用场景](patterns/anti-patterns/忽略使用场景.md)
4. [沉没成本谬误](patterns/anti-patterns/沉没成本谬误.md)
5. [技术选型偏差](patterns/anti-patterns/技术选型偏差.md)

**使用价值**: ⭐⭐⭐⭐⭐ 高价值

---

### 3. 决策框架（decision-frameworks/）

**用途**: 提供系统化的决策工具和检查清单

**框架列表**:

1. [项目启动检查清单](decision-frameworks/项目启动检查清单.md)
2. [技术选型评估表](decision-frameworks/技术选型评估表.md)
3. [风险评估矩阵](decision-frameworks/风险评估矩阵.md)
4. [架构设计原则](decision-frameworks/架构设计原则.md)

**使用价值**: ⭐⭐⭐⭐⭐ 高价值

---

### 4. 技术指南（technical-guides/）

**用途**: 技术实现指南和最佳实践

**指南列表**:
- （待创建）

---

### 5. 工具脚本库（tools-and-scripts/）

**用途**: 可复用的工具和脚本

**脚本列表**:
- `draw-io-forAI/` - draw-io-forAI项目的脚本

---

## 🔍 快速查找

### 按主题查找

- **需求分析问题**: 搜索"需求分析"
- **技术选型问题**: 搜索"技术选型"
- **成本评估问题**: 搜索"成本评估"
- **架构设计问题**: 搜索"架构设计"

### 按教训查找

- **需求分析要深入**: 搜索"需求分析要深入"
- **技术选型要有依据**: 搜索"技术选型要有依据"
- **成本评估要全面**: 搜索"成本评估要全面"

### 按反模式查找

- **演示系统生产化**: `patterns/anti-patterns/演示系统生产化.md`
- **过度工程化**: `patterns/anti-patterns/过度工程化.md`
- **忽略使用场景**: `patterns/anti-patterns/忽略使用场景.md`

---

## 📝 使用指南

### 日常编程
- Cursor Rules 会自动提供反模式警告和检查提醒
- 无需主动查阅知识库

### 需要深入了解时
- **详细案例分析** → `failure-cases/`
- **完整检查清单** → `decision-frameworks/`
- **反模式详情** → `patterns/anti-patterns/`

### 项目结束后
1. **更新 Cursor Rules**：添加新教训摘要
2. **补充知识库**：写入完整案例分析（如有必要）

---

## 🛠️ 知识沉淀流程

### 1. 案例入库标准

**失败案例**:
- 案例摘要（1页纸）
- 详细分析
- 决策复盘
- 技术债务清单
- 预防措施

**成功案例**:
- 案例摘要
- 成功因素分析
- 最佳实践提炼
- 可复用模式

---

### 2. 模式提炼标准

**反模式卡片**:
- 模式名称
- 识别特征
- 危害分析
- 预防措施
- 相关案例

**正模式卡片**:
- 模式名称
- 适用场景
- 实施方法
- 效果评估
- 相关案例

---

### 3. 框架创建标准

**决策框架**:
- 框架说明
- 使用指南
- 检查清单/评估表
- 使用示例

---

## 📚 相关资源

- [工作区指南](../README-WORKSPACE.md)
- [项目索引](../01-projects/README.md)
- [知识迁移报告](知识迁移报告.md)

---

**创建日期**: 2026年1月
**最后更新**: 2026年1月21日
**说明**: 核心规则已整合到 Cursor 全局 Rules，本知识库保留详细参考内容
