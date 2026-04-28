#!/usr/bin/env python3
import os
import re

AGENTS_DIR = r"C:\Users\Administrator\Desktop\AGENTS-COLLECTION-main\AGENTS"
WIKI_DIR = r"C:\Users\Administrator\Desktop\TuriX-CUA-multi-agent-windows\wiki\agents"

def extract_agent_info(content, filename):
    name = filename[:-3]
    desc = ""
    tools = []
    color = "gray"

    name_match = re.search(r'^name:\s*(.+)$', content, re.MULTILINE)
    desc_match = re.search(r'^description:\s*(.+)$', content, re.MULTILINE)
    tools_match = re.search(r'^tools:\s*(.+)$', content, re.MULTILINE)
    color_match = re.search(r'^color:\s*(.+)$', content, re.MULTILINE)

    if name_match:
        name = name_match.group(1).strip()
    if desc_match:
        desc = desc_match.group(1).strip()[:200]
    if tools_match:
        tools = [t.strip() for t in tools_match.group(1).split(',')]
    if color_match:
        color = color_match.group(1).strip()

    return name, desc, tools, color

def convert_to_wiki_page(name, desc, tools, color, platform):
    return f"""# {name}

**Platform**: {platform}
**Color**: {color}
**Tools**: {', '.join(tools) if tools else 'N/A'}

## Description

{desc}

## Usage

Use this agent for: {desc.split('.')[0] if desc else 'general tasks'}

## Metadata

- Type: Agent
- Source: AGENTS-COLLECTION
- Platform: {platform}
"""

os.makedirs(WIKI_DIR, exist_ok=True)

platforms = ['CLAUDE-CODE', 'CURSOR', 'OPENCODE', 'EVERYTHING-CC', 'NEW-AGENTS']
total = 0

for platform in platforms:
    platform_dir = os.path.join(AGENTS_DIR, platform)
    if not os.path.isdir(platform_dir):
        continue

    out_dir = os.path.join(WIKI_DIR, platform)
    os.makedirs(out_dir, exist_ok=True)

    files = [f for f in os.listdir(platform_dir) if f.endswith('.md')]
    for f in files:
        try:
            path = os.path.join(platform_dir, f)
            with open(path, 'r', encoding='utf-8') as file:
                content = file.read()

            name, desc, tools, color = extract_agent_info(content, f)
            page = convert_to_wiki_page(name, desc, tools, color, platform)

            out_path = os.path.join(out_dir, f)
            with open(out_path, 'w', encoding='utf-8') as file:
                file.write(page)
            total += 1
        except Exception as e:
            print(f"Error: {f} - {e}")

print(f"Created {total} wiki pages")