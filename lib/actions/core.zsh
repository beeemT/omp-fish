#!/usr/bin/env zsh

# Core action handlers for basic omp operations

# Action handler: Start a new session
# Usage: :new or :new <prompt>
function _omp_action_new() {
    local input_text="$1"

    # Set fresh session flag
    _OMP_FRESH_SESSION=true
    _OMP_SESSION_STARTED=false

    # If input_text is provided, send it as a new session prompt
    if [[ -n "$input_text" ]]; then
        _omp_exec_interactive "$input_text"
    else
        echo
        _omp_log info "Starting fresh session. Next ': <prompt>' will create a new session."
        BUFFER=""
        CURSOR=0
        zle accept-line
    fi
}

# Action handler: Show help
function _omp_action_help() {
    echo
    echo "omp-zsh plugin - Commands for interacting with omp"
    echo
    echo "Builtin commands:"
    echo "  : <prompt>       Send prompt to omp (starts new session if needed)"
    echo "  :new             Start a new session"
    echo "  :new <prompt>    Start new session and send prompt"
    echo "  :c <prompt>      Continue session with context"
    echo "  :s <prompt>      Suggest a shell command, put it in buffer"
    echo "  :commit          AI-assisted git commit"
    echo "  :commit --dry-run  Preview commit message, put git command in buffer"
    echo "  :stats           Show OMP usage statistics"
    echo
    printf "%s" "Multiline: Shift+Enter in normal mode"
    BUFFER=""
    CURSOR=0
    zle accept-line
}

# Action handler: Default : prompt (continue or start session)
# Usage: : <prompt> or :unknown_command <prompt>
function _omp_action_default() {
    local user_action="$1"
    local input_text="$2"

    # Check if this is an unknown command or a regular prompt
    if [[ -n "$user_action" ]]; then
        # Unknown command with text - treat it as a prompt with the command prefix
        input_text="$user_action $input_text"
    fi

    if [[ -z "$input_text" ]]; then
        _omp_log warning "Usage: : <prompt>"
        return 0
    fi

    # Check if this is a fresh session
    if [[ "$_OMP_FRESH_SESSION" == "true" || "$_OMP_SESSION_STARTED" == "false" ]]; then
        # Fresh session: start new session with bare omp
        _omp_exec_interactive "$input_text"
        _OMP_SESSION_STARTED=true
        _OMP_FRESH_SESSION=false
    else
        # Existing session: continue with -c
        _omp_exec_interactive -c "$input_text"
    fi
}
