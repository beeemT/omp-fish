function __omp_exec_stateless -d "Execute omp in stateless mode"
    set -l prompt $argv[1]

    set -l full_prompt "Output ONLY a raw fish shell command for the following request. Do NOT execute it. Do NOT explain. Do NOT use markdown.

$prompt"

    set -l cmd (omp --no-session -p "$full_prompt")
    or return $status

    set -l cmd (string trim -- $cmd)
    if test -n "$cmd"
        commandline --replace -- $cmd
    end
end
