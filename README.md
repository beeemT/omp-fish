# omp-zsh

A zsh plugin for [oh-my-pi](https://github.com/can1357/oh-my-pi) (`omp`). Turns `:`-prefixed commands into omp prompts directly from your zsh prompt.

## Requirements

- [zsh](https://www.zsh.org/) 5.8+
- [omp](https://github.com/can1357/oh-my-pi) CLI (`omp` on `$PATH`)

## Install

### Oh My Zsh (Recommended)

```zsh
# Clone into custom plugins directory
git clone https://github.com/beeemT/omp-zsh.git ~/.oh-my-zsh/custom/plugins/omp-zsh

# Add to .zshrc plugins list
plugins=(... omp-zsh)
```

### Manual

```zsh
# Copy plugin files into your zsh config
mkdir -p ~/.config/zsh/plugins/omp
git clone https://github.com/beeemT/omp-zsh.git ~/.config/zsh/plugins/omp

# Add to your .zshrc
source ~/.config/zsh/plugins/omp/omp.plugin.zsh
```

### Plugin Managers

**zinit:**
```zsh
zinit load beeemT/omp-zsh
```

**antidote:**
```zsh
# In plugins.txt
beeemT/omp-zsh
```

**zgen:**
```zsh
zgen load beeemT/omp-zsh
```

## Usage

| Command | Description |
|---------|-------------|
| `: <prompt>` | Send prompt to omp (starts new session if needed) |
| `:new` | Start a new session |
| `:new <prompt>` | Start new session and send prompt |
| `:c <prompt>` | Continue session with context (includes last command + exit code) |
| `:s <prompt>` | Suggest a shell command — output is placed in the buffer |
| `:commit` | AI-assisted git commit |
| `:commit --dry-run` | Preview commit message, put git command in buffer |
| `:stats` | Show omp usage statistics |
| `:help` | List available commands |

### Examples

```zsh
# Start a conversation
: explain the authentication middleware

# Continue the same session
: and how would I add rate limiting?

# Get a shell command — output lands in your buffer, press Enter to execute
:s find all .ts files modified in the last week

# Continue with last command context (prepends last command + exit code)
:c why did this fail

# Start fresh session
:new

# Start fresh and send first prompt
:new explain the middleware pattern

# AI commit
:commit

# Preview commit message (puts git command in buffer)
:commit --dry-run
```

### Multiline Prompts

Type multiline prompts using Shift+Enter. All lines are sent as a single prompt:

```
: This is line 1
This is line 2
This is line 3
```

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `OMP_BIN` | `omp` | Path to OMP CLI binary |

```zsh
# Custom omp binary location
export OMP_BIN="/path/to/custom/omp"
```

## How it Works

The plugin registers a ZLE widget (`omp-accept-line`) that intercepts lines starting with `:`. It parses the command and routes to the appropriate handler:

- `: <prompt>` → `omp "<prompt>"` (new session) or `omp -c "<prompt>"` (continue)
- `:new` → resets session state; with prompt: `omp "<prompt>"`
- `:c <prompt>` → `omp -c "<context>\n<prompt>"` (with last command context)
- `:s <prompt>` → `omp --no-session -p "<prompt>"` (stateless, output to buffer)
- `:commit` → `omp commit`
- `:commit --dry-run` → `omp commit --dry-run`
- `:stats` → `omp stats`
- `:help` → displays built-in help text

## File Structure

```
omp-zsh/
├── omp.plugin.zsh           # Main plugin entry point
├── lib/
│   ├── config.zsh           # Configuration variables
│   ├── dispatcher.zsh       # Main ZLE widget and command routing
│   ├── helpers.zsh          # Utility functions (_omp_exec_interactive, _omp_log)
│   ├── context.zsh          # Terminal context capture
│   ├── bindings.zsh         # Key bindings
│   ├── completion.zsh       # Completion widget
│   └── actions/
│       ├── core.zsh         # :new, :help, default : handling
│       ├── session.zsh      # :c (continue with context)
│       ├── suggest.zsh      # :s (command suggestion)
│       ├── commit.zsh       # :commit, :commit --dry-run
│       └── stats.zsh        # :stats
├── completions/
│   └── _omp                 # Zsh completion function
└── README.md
```

## License

[MIT](LICENSE)
