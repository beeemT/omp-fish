# omp-fish CLI wrapper
# Note: fish automatically makes functions in functions/ available by name

function __omp_exec_session -d "Execute omp in session mode"
    set -l prompt $argv[1]
    omp --continue -p $prompt
end

function __omp_exec_stateless -d "Execute omp in stateless mode with auto-context"
    set -l prompt $argv[1]

    # Build auto-context
    set -l context (__omp_build_context)

    # Combine prompt with context
    set -l full_prompt "$prompt

Context:
$context"

    # Stateless mode doesn't use model selection (--no-session)
    omp --no-session -p $full_prompt
end
