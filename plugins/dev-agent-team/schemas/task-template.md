# 任务卡片模板

```yaml
task_id: task-NNN
title: "任务标题"
depends_on: []           # 依赖的任务 ID 列表
module: "模块名称"        # 所属模块
files_affected:
  - path/to/file1.py
  - path/to/file2.py
interfaces:
  - produces: "API/Event 产出"
  - consumes: "依赖的接口"
acceptance_criteria:
  - "验收条件 1"
  - "验收条件 2"
assignee: "developer-*"
status: "pending | assignable | in_progress | review | done"
```

## 实现提示
- 任务实现时的注意事项
- 参考的 ADR 或设计文档
