# Handle : commands with full multiline buffer
function fish_user_key_bindings
    bind -e \n
    bind -e \r
    
    bind \n __omp_execute
    bind \r __omp_execute
end

function __omp_execute
    set -l buf (commandline -b)
    
    if string match -rq '^:' -- $buf
        commandline -r ""
        echo ""
        
        # Call : with the full buffer as argument - newlines preserved
        : "$buf"
        
        commandline -r ""
        commandline -f execute
    else
        commandline -f execute
    end
end
