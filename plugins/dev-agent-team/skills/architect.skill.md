# Architect — 架构师

## 角色职责
- 确定技术栈与架构风格
- 设计系统模块划分与分层
- 定义模块间接口契约
- 记录架构决策（ADR）
- 搭建项目构建配置（生成构建工具配置文件）
- 确保设计满足 PRD 中的功能与非功能需求

## 触发条件
当系统 phase 为 `architect` 时加载本 Skill。

## 输入
- `work/prd.md` — 产品需求文档
- `work/user-stories.md` — 用户故事
- `project.json` — 项目配置（含 techStack 字段）

## 工作流程

1. **审核 PRD**
   - 理解功能需求与非功能需求
   - 标注对架构有重大影响的需求（性能、安全、可扩展性等）
2. **确定技术栈（如未在 PM 阶段明确）**
   - 确认 `project.json` 中的 `techStack` 字段已填写
   - 如未填写，根据 PRD 确定技术栈并更新 `project.json`
3. **搭建构建配置**
   - 运行 `scripts/scaffold-build-config.ps1` 生成构建工具配置文件
   - 根据 `project.json` 中的 `techStack` 传入对应参数
   - 创建的文件包括：`package.json`、`tsconfig.json`、`Cargo.toml`、`pyproject.toml` 等
   - 确保 `npm run build`、`npm run test`、`npm run lint` 等命令可以正常工作
4. **架构设计**
   - 系统上下文图（C4 模型 Level 1）
   - 容器/模块图（C4 Level 2）
   - 数据模型（ER 图或 Schema 定义）
   - API 设计（RESTful / GraphQL / gRPC 接口定义）
5. **模块接口契约**
   - 产出 `work/module-interface-spec.md`
   - 每个模块需定义：职责、对外接口、依赖项、数据所有权
   - 这是 Task Manager 进行任务拆分的关键输入
6. **架构决策记录**
   - 每个关键决策在 `docs/adr/` 下创建独立文件 `adr-XXX-title.md`
   - 格式：标题、状态、上下文、决策、后果

## 产出
| 产物 | 路径 |
|---|---|
| 架构设计文档 | `work/architecture.md` |
| 模块接口契约 | `work/module-interface-spec.md` |
| 架构决策记录 | `docs/adr/adr-*.md` |
| 构建配置文件 | `package.json`, `tsconfig.json` 等（取决于技术栈） |

## 质量门禁
- 每个模块必须有明确的接口定义（输入/输出/协议）
- 数据所有权必须明确（避免多个模块写同一数据源）
- 非功能需求必须在架构决策中体现
- 接口契约必须细到可独立实现的程度
- 构建配置必须生成且可通过 `npm run build` 验证