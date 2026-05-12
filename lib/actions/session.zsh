#!/usr/bin/env zsh

# Session management action handlers

# Action handler: Continue session with context
# Usage: :c <prompt>
# Prepends last command and exit code to prompt
function _omp_action_continue() {
    local input_text="$1"

    # Build context from terminal capture
    local context=$(_omp_build_context)

    if [[ -n "$context" ]]; then
        # Prepend context to prompt (auto-exits after one turn)
        _omp_exec_interactive_once -c "${context}

${input_text}"
    else
        # No context available, just continue (auto-exits after one turn)
        _omp_exec_interactive_once -c "$input_text"
    fi
}
