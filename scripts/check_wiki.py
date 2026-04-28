#!/usr/bin/env python3
import sys
sys.stdout.reconfigure(encoding='utf-8')
sys.stderr.reconfigure(encoding='utf-8')

from llmwikify.cli.commands import status, write_page, init
import argparse

args = argparse.Namespace(verbose=False, json=False, file=None)
try:
    status(args)
except Exception as e:
    print(f"Status error: {e}")
    init(args)