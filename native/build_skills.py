#!/usr/bin/env python3
import argparse, shutil
from pathlib import Path

SKIP_NAMES = {'.git', '.hg', '.svn', '__pycache__', 'node_modules', 'venv', '.venv', '.tox', '.mypy_cache'}
SKIP_SUFFIXES = {'.pyc', '.pyo'}
SKIP_FILES = {'auth.json', '.env', '.env.local'}

def ignored(_path, names):
    return {name for name in names if name in SKIP_NAMES or name in SKIP_FILES or Path(name).suffix.lower() in SKIP_SUFFIXES}

def discover(source):
    found = {}
    for child in sorted(source.iterdir()):
        if child.name == '.system' and child.is_dir():
            candidates = child.iterdir()
        else:
            candidates = [child]
        for item in candidates:
            if item.is_dir() and (item / 'SKILL.md').is_file() and item.name not in found:
                found[item.name] = item
    return found

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--source', action='append', type=Path, required=True)
    parser.add_argument('--destination', type=Path, required=True)
    args = parser.parse_args()
    selected = {}
    for source in args.source:
        if not source.is_dir():
            raise SystemExit(f'missing source: {source}')
        for name, path in discover(source).items():
            if name not in selected:
                selected[name] = path
    if not selected:
        raise SystemExit('no skills found')
    args.destination.mkdir(parents=True, exist_ok=True)
    for name, source in selected.items():
        target = args.destination / name
        if target.exists():
            shutil.rmtree(target)
        shutil.copytree(source, target, ignore=ignored, symlinks=False)
    print(f'bundled_skills={len(selected)} destination={args.destination}')

if __name__ == '__main__':
    main()
