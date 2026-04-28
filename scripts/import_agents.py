#!/usr/bin/env python3
import os
import sys
import subprocess

AGENTS_DIR = r"C:\Users\Administrator\Desktop\AGENTS-COLLECTION-main\AGENTS"
PLATFORMS = ['CLAUDE-CODE', 'CURSOR', 'OPENCODE']

def import_agent(filepath):
    name = os.path.splitext(os.path.basename(filepath))[0]
    name = name.replace('-', '_')

    result = subprocess.run([
        sys.executable, '-m', 'llmwikify', 'write_page', name,
        '--file', filepath
    ], env={**os.environ, 'PYTHONIOENCODING': 'utf-8', 'PYTHONUTF8': '1'},
       capture_output=True, text=True)

    if result.returncode == 0:
        print(f"OK: {name}")
    else:
        print(f"FAIL: {name} - {result.stderr[:100]}")

total = 0
for platform in PLATFORMS:
    dir_path = os.path.join(AGENTS_DIR, platform)
    if not os.path.isdir(dir_path):
        continue

    files = [f for f in os.listdir(dir_path) if f.endswith('.md')]

    for f in files:
        import_agent(os.path.join(dir_path, f))
        total += 1

print(f"Total: {total}")