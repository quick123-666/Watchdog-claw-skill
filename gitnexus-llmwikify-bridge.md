# GitNexus → LLMWiki Bridge

> 把 GitNexus 图谱导入到 llmwikify

## 使用

```bash
# 1. 索引项目
npx gitnexus analyze

# 2. 导出图谱数据
python scripts/export_gitnexus.py

# 3. 导入 llmwikify
py -m llmwikify write_page "gitnexus-huashu" --file "knowledge/gitnexus/huashu-design_files.md"
py -m llmwikify write_page "gitnexus-symbols" --file "knowledge/gitnexus/huashu-design_functions.md"
```

## LLMWiki 命令

```bash
# 搜索
py -m llmwikify search "huashu"

# 读取页面
py -m llmwikify read_page "gitnexus-huashu"

# 图谱查询
py -m llmwikify graph-query "main"
```

## 自动导入脚本

```python
import subprocess
import os

def import_to_llmwikify():
    files = [
        ("knowledge/gitnexus/huashu-design_files.md", "gitnexus-huashu-files"),
        ("knowledge/gitnexus/huashu-design_functions.md", "gitnexus-huashu-functions"),
        ("knowledge/gitnexus/Mercury-Crab-Agent_files.md", "gitnexus-mc-files"),
        ("knowledge/gitnexus/Mercury-Crab-Agent_functions.md", "gitnexus-mc-functions"),
    ]
    
    for src_file, page_name in files:
        if os.path.exists(src_file):
            print(f"Importing {page_name}...")
            subprocess.run([
                "py", "-m", "llmwikify", "write_page", page_name,
                "--file", src_file
            ], env={**os.environ, "PYTHONIOENCODING": "utf-8"})
    
    print("Done!")

if __name__ == "__main__":
    import_to_llmwikify()
```