function __omp_exec_session -d "Execute omp in session mode"
    set -l prompt $argv[1]
    if set -q __omp_new_session
        omp "$prompt"
        set -e __omp_new_session
    else
        omp --continue "$prompt"
    end
    or return $status
end
