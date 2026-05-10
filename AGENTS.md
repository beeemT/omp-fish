# omp-zsh Agent Guidelines

## ZLE Widget Output Patterns

ZLE widgets run in a special context where stdout is captured. Output printed with `echo` goes to the terminal but gets redrawn by ZLE after the widget returns.

### Durable Output
To print messages that persist after the widget returns:

```zsh
echo
echo "Your message here"
BUFFER=""
CURSOR=0
zle accept-line
```

This pattern:
1. `echo` prints to terminal
2. `BUFFER=""` clears the edit buffer
3. `CURSOR=0` resets cursor position
4. `zle accept-line` accepts the empty line, triggering a fresh prompt redraw

### Interactive Commands (omp)
For commands that run omp interactively:

```zsh
function _omp_exec_interactive() {
    local -a cmd
    cmd=($_OMP_BIN "$@")
    echo
    "${cmd[@]}" < $TTY
    # Clear buffer and accept empty line to get fresh prompt
    BUFFER=""
    CURSOR=0
    zle accept-line
}
```

Key points:
- Use `< $TTY` for stdin (not `</dev/tty>` which crashes in some terminals)
- `echo` before running ensures clean output
- Clear buffer and accept-line after ensures fresh prompt

### Do NOT Use
- `zle -I` - invalidates the display, causes flickering
- `zle -M` - message area, but doesn't persist reliably across all terminals (e.g., Warp)
- `zle reset-prompt` - inconsistent behavior, prefer `zle accept-line`

## Log Messages

Use the `_omp_log` helper for consistent formatting:

```zsh
_omp_log info "Starting fresh session."
_omp_log warning "Unknown command: :foo"
```

The helper handles colors. Current format:
- No timestamps
- No icons or symbols
- Colored text only (level determines color)

## Error States

For errors/warnings that should clear the buffer:

```zsh
echo
_omp_log warning "Unknown command: :$user_action"
BUFFER=""
CURSOR=0
zle accept-line
```

## File Locations

- **Installed**: `~/.oh-my-zsh/custom/plugins/omp-zsh/`
- **Repo**: Current working directory

Ask the user whether to sync changes to both locations.
