# omp-fish shared utilities
# Color constants for log output
set -g __omp_color_info (tput setaf 4)   # Blue
set -g __omp_color_success (tput setaf 2) # Green
set -g __omp_color_warn (tput setaf 3)    # Yellow
set -g __omp_color_error (tput setaf 1)   # Red
set -g __omp_color_reset (tput sgr0)

function __omp_escape -d "Escape string for CLI"
    # Use sed for reliable backslash escaping of quotes
    printf '%s' $argv | sed "s/['\"\`]/\\\\&/g"
end

function __omp_detect_shell -d "Detect current shell"
    echo "fish"
end

function __omp_log -d "Log with level"
    set -l level $argv[1]
    set -l msg $argv[2..-1]
    echo "[omp:$level] $msg" >&2
end

function __omp_build_context -d "Build auto-context for :s commands"
    # Current directory
    set -l cwd $PWD
    # Shell type
    set -l shell (__omp_detect_shell)

    echo "Current directory: $cwd\nShell: $shell"
end
