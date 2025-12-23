import os
import asyncio
from pathlib import Path

import discord
from discord.ext import commands


ASTART_PATH = Path(os.environ.get("ASTART_PATH", "astart"))
try:
	ASTART_SCRIPT = ASTART_PATH.resolve()
except Exception:
	ASTART_SCRIPT = ASTART_PATH

# Optional: embed your bot token here (NOT RECOMMENDED for production).
# If `DISCORD_TOKEN` env var is set, that value takes precedence.
# Example: BOT_TOKEN = "Mz...your_token_here..."
BOT_TOKEN = ""  # <-- paste your bot token here if you want it built into the script


def parse_log_paths(astart_file: Path):
	log_dir = None
	activity = None
	pid_dir = None
	try:
		text = astart_file.read_text()
		for line in text.splitlines():
			if line.strip().startswith('LOG_DIR='):
				val = line.split('=', 1)[1].strip().strip('"').strip("'")
				val = val.replace('$HOME', str(Path.home()))
				log_dir = Path(val).expanduser()
			if line.strip().startswith('ACTIVITY_LOG='):
				val = line.split('=', 1)[1].strip().strip('"').strip("'")
				if log_dir:
					val = val.replace('$LOG_DIR', str(log_dir))
				activity = Path(val).expanduser()
			if line.strip().startswith('PID_DIR='):
				val = line.split('=', 1)[1].strip().strip('"').strip("'")
				if log_dir:
					val = val.replace('$LOG_DIR', str(log_dir))
				pid_dir = Path(val).expanduser()
	except Exception:
		pass

	if not log_dir:
		log_dir = (ASTART_PATH.parent / 'logs')
	if not pid_dir:
		pid_dir = (log_dir / 'pids')
	if not activity:
		activity = (log_dir / 'astart_activity.log')
	return log_dir, pid_dir, activity


LOG_DIR, PID_DIR, ACTIVITY_LOG = parse_log_paths(ASTART_SCRIPT)

intents = discord.Intents.default()
intents.message_content = True
bot = commands.Bot(command_prefix='!', intents=intents, help_command=None)


def authorized(user_id: int) -> bool:
	allowed = os.environ.get('ALLOWED_USER_IDS', '')
	if not allowed:
		return True
	try:
		ids = {int(x.strip()) for x in allowed.split(',') if x.strip()}
		return user_id in ids
	except Exception:
		return False


async def run_astart_flag(flag: str, timeout: int = 120):
	if not ASTART_SCRIPT.exists():
		return 1, "", f"astart script not found at {ASTART_SCRIPT}"

	proc = await asyncio.create_subprocess_exec(
		'bash', str(ASTART_SCRIPT), flag,
		stdout=asyncio.subprocess.PIPE,
		stderr=asyncio.subprocess.PIPE,
	)
	try:
		out, err = await asyncio.wait_for(proc.communicate(), timeout=timeout)
	except asyncio.TimeoutError:
		proc.kill()
		return 124, '', 'timeout'
	return proc.returncode, (out.decode() if out else ''), (err.decode() if err else '')


@bot.event
async def on_ready():
	print(f'Bot connected as {bot.user} (ASTART={ASTART_SCRIPT})')


@bot.command(name='run')
async def run_cmd(ctx: commands.Context, flag: str):
	if not authorized(ctx.author.id):
		await ctx.reply('You are not authorized to run this command.')
		return
	if not flag.startswith('-'):
		flag = f'-{flag}'
	await ctx.reply(f'Executing astart {flag}...')
	code, out, err = await run_astart_flag(flag)
	msg = f'Exit {code}\n'
	if out:
		msg += f'Output:\n{out}\n'
	if err:
		msg += f'Error:\n{err}\n'
	if len(msg) > 1900:
		msg = msg[:1900] + '\n...(truncated)'
	await ctx.send(f'```\n{msg}\n```')


@bot.command(name='status')
async def status_cmd(ctx: commands.Context):
	if not authorized(ctx.author.id):
		await ctx.reply('You are not authorized to run this command.')
		return
	lines = []

	# Build a concise list of running process NAMES (from pid files)
	running = []
	missing = []
	if PID_DIR.exists():
		pids = list(PID_DIR.glob('*.pid'))
		for p in pids:
			name = p.stem
			try:
				pid_text = p.read_text().splitlines()[0].strip()
				pid = int(pid_text)
			except Exception:
				pid = None
			if pid:
				try:
					os.kill(pid, 0)
					running.append(f'{name} (pid={pid})')
				except Exception:
					missing.append(f'{name} (pid={pid})')
			else:
				missing.append(f'{name} (no-pid)')
	else:
		lines.append(f'PID_DIR not found: {PID_DIR}')

	if running:
		lines.append('Running processes:')
		for r in running:
			lines.append(f'- {r}')
	else:
		lines.append('No running processes detected.')

	if missing:
		lines.append('Known but not running:')
		for m in missing:
			lines.append(f'- {m}')

	msg = '\n'.join(lines)
	if len(msg) > 1900:
		msg = msg[:1900] + '\n... (truncated)'
	await ctx.send(f'```\n{msg}\n```')


@bot.command(name='help')
async def help_cmd(ctx: commands.Context):
	# Build a rich embed help message for Discord
	embed = discord.Embed(
		title="Astart Control Bot — Help",
		description="Run and monitor the `astart` launcher from Discord.",
		color=0x2ecc71,
	)
	embed.add_field(
		name="Commands",
		value=(
			"`!run <flag>` — Run `astart` with a flag (examples below)\n"
			"`!status` — Show pid files and recent activity log\n"
			"`!help` — Show this message"
		),
		inline=False,
	)
	embed.add_field(
		name="Common flags",
		value=(
			"`-c` start Web Interface\n"
			"`-a` start AI Chatbot API only\n"
			"`-w` run whole system (backend + web UI + API)\n"
			"`-b` start backend only\n"
			"`-x` start login/registration script\n"
			"`-s` stop all services\n"
			"`-u` update production server"
		),
		inline=False,
	)
	embed.add_field(
		name="Usage examples",
		value=(
			"`!run -c` — start the web interface\n"
			"`!run -s` — stop all services\n"
			"`!status` — show recent activity and running pids"
		),
		inline=False,
	)
	embed.add_field(
		name="Notes",
		value=(
			"• Ensure `DISCORD_TOKEN` env var is set to your bot token.\n"
			"• If using message commands, enable the Message Content Intent in the Developer Portal.\n"
			"• Optional env vars: `ALLOWED_USER_IDS` (comma list), `ASTART_PATH` (path to `astart`)."
		),
		inline=False,
	)
	embed.set_footer(text=f"astart: {ASTART_SCRIPT} | logs: {LOG_DIR}")

	await ctx.send(embed=embed)


if __name__ == '__main__':
	token = os.environ.get('DISCORD_TOKEN')
	if not token:
		print('Please set DISCORD_TOKEN in the environment.')
		raise SystemExit(1)
	try:
		bot.run(token)
	except Exception as exc:
		# Provide a clearer message for common login/token errors
		from discord.errors import LoginFailure
		if isinstance(exc, LoginFailure):
			print('Login failed: invalid DISCORD_TOKEN. Ensure you set your bot token (not a user token).')
		else:
			print('Bot failed to start:', exc)
		raise

