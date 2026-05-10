#!/usr/bin/env zsh

# Suggest action handlers

# Action handler: Suggest a shell command
# Usage: :s <prompt>
# Generates a command using omp --no-session and puts it in the buffer
function _omp_action_suggest() {
    local input_text="$1"

    # Build context from terminal capture
    local context=$(_omp_build_context)

    # Generate command using stateless mode with clear instruction
    local prompt
    if [[ -n "$context" ]]; then
        prompt="$context
        
Generate a single zsh command / script to fulfill the following request.
Do not execute the task but generate a command that the user can execute themselves.
Answer with nothing but the command as plain text.

Request: $input_text"
    else
        prompt="Generate a single zsh command / script to fulfill the following request.
Do not execute the task but generate a command that the user can execute themselves.
Answer with nothing but the command as plain text.

Request: $input_text"
    fi

    # Show generating indicator
    echo -n "Generating command... "
    zle -I
    
    # Run omp and capture output
    local result
    result=$($_OMP_BIN --no-pty -p "$prompt")
    
    # Clear the generating line
    echo -ne "\033[2K\r"
    zle -I
    
    echo "$result" > /tmp/omp-zsh-last-action.txt
    
    if [[ -n "$result" ]]; then
        # Remove code fences
        result="${result//\`\`\`zsh/}"
        result="${result//\`\`\`bash/}"
        result="${result//\`\`\`sh/}"
        result="${result//\`\`\`/}"
        result="${result//\`/}"
        
        # Trim leading whitespace
        while [[ "$result" == [[:space:]]* ]]; do
            result="${result#[[:space:]]}"
        done
        
        # Trim trailing whitespace
        while [[ "$result" == *[[:space:]] ]]; do
            result="${result%[[:space:]]}"
        done
        
        BUFFER="$result"
        CURSOR=${#BUFFER}
        zle reset-prompt
        return 0
    fi
    
    BUFFER=""
    zle reset-prompt
}
