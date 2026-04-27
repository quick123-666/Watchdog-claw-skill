# GitNexus Bridge to Knowledge

> 把 GitNexus 图谱数据导出为知识库格式

## 核心机制

GitNexus 使用 **LadybugDB** 存储图谱（`.gitnexus/lbug`），支持 Cypher 查询。

## 使用方式

```bash
# 1. 索引项目
npx gitnexus analyze

# 2. 查看符号
npx gitnexus context "FunctionName"

# 3. 查看影响
npx gitnexus impact "FunctionName"

# 4. 语义搜索
npx gitnexus query "keyword"
```

## 集成到项目

在 `skills/gitnexus-export.py`:

```python
import subprocess
import json

def get_symbol_context(symbol_name, repo=None):
    cmd = ["npx", "gitnexus", "context", symbol_name]
    if repo:
        cmd.extend(["--repo", repo])
    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.stdout

def export_to_knowledge(symbol_name, output_file):
    context = get_symbol_context(symbol_name)
    with open(output_file, "w", encoding="utf-8") as f:
        f.write(context)
    print(f"✅ 已导出到 {output_file}")

if __name__ == "__main__":
    import sys
    symbol = sys.argv[1] if len(sys.argv) > 1 else "main"
    export_to_knowledge(symbol, f"knowledge/gitnexus_{symbol}.md")
```

## MCP Server

启动 MCP 让 AI 实时查询：

```bash
npx gitnexus mcp
```

## 图谱数据

```json
{
  "files": 119,
  "nodes": 1824,
  "edges": 2793,
  "communities": 82,
  "processes": 73
}
```