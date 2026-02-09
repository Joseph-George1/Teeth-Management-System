import os
import asyncio
from pathlib import Path
from aiohttp import web, ClientSession

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


async def get_health_status():
	"""Fetch health status from AI chatbot API."""
	try:
		async with ClientSession() as session:
			async with session.get('http://127.0.0.1:5010/health', timeout=5) as response:
				data = await response.json()
				return data
	except Exception as e:
		return {
			'status': 'error',
			'ai_initialized': False,
			'questions_loaded': False,
			'error': str(e)
		}


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
	
	# Get health status from AI chatbot API
	health = await get_health_status()
	
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
	
	# Determine embed color based on status
	if health.get('status') == 'ok' and len(running) > 0:
		color = 0x2ecc71  # Green - everything is good
	elif health.get('status') == 'ok' or len(running) > 0:
		color = 0xf39c12  # Orange - partially working
	else:
		color = 0xe74c3c  # Red - problems detected
	
	# Create colorful embed
	embed = discord.Embed(
		title="🔍 System Status",
		color=color,
		description="Current status of all services and components"
	)
	
	# Add AI Chatbot Health
	status_emoji = "✅" if health.get('status') == 'ok' else "❌"
	ai_emoji = "✅" if health.get('ai_initialized') else "❌"
	questions_emoji = "✅" if health.get('questions_loaded') else "❌"
	
	health_text = f"{status_emoji} **Status:** {health.get('status', 'unknown')}\n"
	health_text += f"{ai_emoji} **AI Initialized:** {health.get('ai_initialized', False)}\n"
	health_text += f"{questions_emoji} **Questions Loaded:** {health.get('questions_loaded', False)}"
	
	if 'error' in health:
		health_text += f"\n⚠️ **Error:** {health['error']}"
	
	embed.add_field(name="🤖 AI Chatbot API", value=health_text, inline=False)
	
	# Add Running Processes
	if running:
		running_text = '\n'.join([f'🟢 {r}' for r in running])
		if len(running_text) > 1024:
			running_text = running_text[:1020] + '\n...'
		embed.add_field(name="⚙️ Running Processes", value=running_text, inline=False)
	else:
		embed.add_field(name="⚙️ Running Processes", value="⚪ No running processes detected", inline=False)
	
	# Add Missing/Stopped Processes
	if missing:
		missing_text = '\n'.join([f'🔴 {m}' for m in missing])
		if len(missing_text) > 1024:
			missing_text = missing_text[:1020] + '\n...'
		embed.add_field(name="⏸️ Stopped Processes", value=missing_text, inline=False)
	
	embed.set_footer(text=f"PID Dir: {PID_DIR} | Logs: {LOG_DIR}")
	
	await ctx.send(embed=embed)


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
	# Prefer environment variable, fall back to embedded BOT_TOKEN constant
	token = os.environ.get('DISCORD_TOKEN') or BOT_TOKEN
	if not token:
		print('Please set DISCORD_TOKEN in the environment or edit BOT_TOKEN in the script.')
		raise SystemExit(1)
	
	try:
		bot.run(token)
	except Exception as exc:
		# Provide a clearer message for common login/token errors
		from discord.errors import LoginFailure
		if isinstance(exc, LoginFailure):
			print('Login failed: invalid token. Ensure you set your bot TOKEN correctly (bot token, not user token).')
		else:
			print('Bot failed to start:', exc)
		raise

