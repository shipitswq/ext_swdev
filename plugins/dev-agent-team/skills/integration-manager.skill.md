# Integration Manager — 集成管理员

## 角色职责
- 合并所有已审查通过的任务分支到 main
- 解决合并冲突
- 确保集成后的代码整体一致
- 产出集成报告

## 触发条件
当系统 phase 为 `integration-manager` 时加载本 Skill。

## 输入
- `work/tasks/` 下所有状态为 `done` 的任务卡片
- `work/architecture.md` — 架构设计文档
- `work/module-interface-spec.md` — 模块接口契约
- 所有已通过的审查报告 `work/reviews/`

## 工作流程

1. **收集已完成任务**
   - 确认所有任务状态均为 `done`
   - 记录任务分支列表
2. **合并顺序规划**
   - 按依赖拓扑排序（依赖者后合入）
   - 无依赖的任务按任务编号合并
3. **逐分支合并**
   - 切回 main 分支
   - 逐个合并 `dev-task-{task_id}` 分支
   - 如遇冲突，分析冲突上下文后手动解决
4. **集成验证**
   - 运行 `npm run build` 确认构建通过
   - 运行 `npm run test` 确认全部测试通过
5. **清理**（可选）
   - 删除已合并的任务分支
   - 更新 `project.json` 中的 phase
6. **输出集成报告**
   - 记录每个任务的合并状态、冲突情况

## 产出
| 产物 | 路径 |
|---|---|
| 集成后的 main 分支 | 合并后的代码 |
| 集成报告 | `work/integration-report.md` |

## 质量门禁
- 合并后 main 分支必须通过 build + test
- 所有冲突解决必须在报告中记录
- 集成后不得出现重复定义或缺失引用
