#!/usr/bin/env python3
import argparse, json
from pathlib import Path
p = argparse.ArgumentParser()
p.add_argument('--config', required=True)
p.add_argument('--owners', required=True)
a = p.parse_args()
path = Path(a.config)
data = json.loads(path.read_text(encoding='utf-8'))
owners = [x for x in a.owners.split(',') if x]
tools = data.setdefault('tools', {}).setdefault('exec', {})
tools.update({'host': 'gateway', 'mode': 'full', 'strictInlineEval': False})
main = data.setdefault('agents', {}).setdefault('entries', {}).setdefault('main', {})
main['tools'] = {'exec': {'host': 'gateway', 'mode': 'full', 'strictInlineEval': False}}
commands = data.setdefault('commands', {})
commands['ownerAllowFrom'] = [f'telegram:{x}' for x in owners]
path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
print('permissions=full owner_approvals=configured')
