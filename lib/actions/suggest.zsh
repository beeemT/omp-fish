#!/usr/bin/env zsh

# Suggest action handlers

# Action handler: Suggest a shell command
# Usage: :s <prompt>
# Generates a command using omp --no-session and puts it in the buffer
function _omp_action_suggest() {
    local input_text="$1"

    echo

    # Build context from terminal capture
    local context=$(_omp_build_context)

    # Generate command using stateless mode with clear instruction
    local prompt
    if [[ -n "$context" ]]; then
        prompt="$context
        
Generate a zsh command / script to fulfill the following request.
Do not execute the task but generate a command that the user can execute themselves.
Answer with nothing but the command.

Request: $input_text"
    else
        prompt="Generate a zsh command / script to fulfill the following request.
Do not execute the task but generate a command that the user can execute themselves.
Answer with nothing but the command.

Request: $input_text"
    fi

    local result
    result=$($_OMP_BIN --no-session -p "$prompt")

    if [[ -n "$result" ]]; then
        # Remove code fences and backticks
        result="${result//\`\`\`*/}"
        result="${result//\`/}"
        
        # Take the last non-empty line (the actual command)
        local last_line="${result##*$'\n'}"
        last_line="${last_line%% }"
        last_line="${last_line## }"
        
        # Put the suggested command in the buffer
        BUFFER="$last_line"
        CURSOR=${#BUFFER}
        zle reset-prompt
    else
        _omp_reset
    fi
}
