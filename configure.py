import argparse
import json
import os
import pathlib
import re
import secrets

parser = argparse.ArgumentParser()
parser.add_argument('--settings', required=True)
parser.add_argument('--root', required=True)
parser.add_argument('--workspace', default='/root/.openclaw/workspace')
parser.add_argument('--overwrite', action='store_true')
args = parser.parse_args()
settings = json.loads(pathlib.Path(args.settings).read_text())
root = pathlib.Path(args.root)
root.mkdir(parents=True, exist_ok=True)
config = root / 'openclaw.json'
if config.exists() and not args.overwrite:
    raise SystemExit('Refusing to overwrite an existing member configuration')
member = settings['member']
for key in ('telegram_token', 'api_key', 'base_url', 'model'):
    if not str(settings.get(key, '')).strip() or str(settings[key]).startswith(('ENTER_', 'REPLACE_')):
        raise SystemExit(f'Missing real customer setting: {key}')
if not re.fullmatch(r'[a-z][a-z0-9_-]{0,63}', member):
    raise SystemExit('Invalid member name')
owners = settings['owner_ids']
if not owners or any(not re.fullmatch(r'[1-9][0-9]*', str(owner)) for owner in owners):
    raise SystemExit('Explicit positive Telegram owner IDs required')
os.umask(0o077)
(root / 'telegram.token').write_text(settings['telegram_token'].strip() + '\n')
account = {
    'enabled': True, 'tokenFile': str(root / 'telegram.token'),
    'dmPolicy': 'allowlist', 'allowFrom': [str(x) for x in owners],
    'groupPolicy': 'allowlist', 'groupAllowFrom': [str(x) for x in owners],
}
if settings.get('group_id'):
    account['groups'] = {str(settings['group_id']): {'requireMention': False, 'allowFrom': [str(x) for x in owners]}}
document = {
    'gateway': {'mode': 'local', 'bind': 'loopback', 'auth': {'mode': 'token', 'token': secrets.token_hex(32)}},
    'secrets': {'providers': {'customer': {'source': 'file', 'path': str(root / 'member-provider.secret'), 'mode': 'singleValue'}}},
    'models': {'providers': {'customer': {
        'baseUrl': settings['base_url'], 'apiKey': {'source': 'file', 'provider': 'customer', 'id': 'value'},
        'api': settings.get('api', 'openai-completions'),
        'models': [{'id': settings['model'], 'name': settings['model']}],
    }}},
    'agents': {'defaults': {'workspace': args.workspace, 'model': {'primary': 'customer/' + settings['model']}},
               'entries': {'main': {'name': settings.get('assistant_name', member)}}},
    'channels': {'telegram': {'enabled': True, 'defaultAccount': member, 'accounts': {member: account}}},
    'bindings': [{'agentId': 'main', 'match': {'channel': 'telegram', 'accountId': member}}],
    'commands': {'ownerAllowFrom': ['telegram:' + str(owner) for owner in owners]},
    'tools': {'exec': {'host': 'gateway', 'mode': 'full', 'strictInlineEval': False}},
}
config.write_text(json.dumps(document, ensure_ascii=False, indent=2) + '\n')
config.chmod(0o600)
(root / 'telegram.token').chmod(0o600)
(pathlib.Path(args.workspace)).mkdir(parents=True, exist_ok=True)
(root / 'member-provider.secret').write_text(settings['api_key'].strip() + '\n')
(root / 'member-provider.secret').chmod(0o600)
