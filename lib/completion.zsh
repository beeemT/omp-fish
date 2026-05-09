#!/usr/bin/env zsh

# Custom completion widget for omp plugin

function omp-completion() {
    local current_word="${LBUFFER##* }"

    # Handle :command completion
    if [[ "${LBUFFER}" =~ "^:"? ]]; then
        # Show completions for : commands
        local -a commands
        commands=(
            "new:start a new session"
            "c:continue with context"
            "s:suggest a command"
            "commit:AI-assisted git commit"
            "stats:show usage statistics"
            "help:show help"
        )

        local -a completions
        completions=("${(f)$(printf '%s\n' "${commands[@]}" 2>/dev/null)}")

        # Use menu-select if available, otherwise fall back
        if zstyle -t ':completion:*' menu; then
            compadd -a commands
            return 0
        fi
    fi

    # Fall back to default completion
    zle expand-or-complete
}

# Register completion widget
zle -N omp-completion
