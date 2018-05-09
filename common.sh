shopt -s expand_aliases

function guessUnitName()
{
    local path=$PWD
    
    while [ ! "$(dirname $path)" == "$HOME" ]
    do
        path=$(dirname $path)
        
        if [ "$path" == "/" ]; then
            echo "Could not guess unit name" >&2
            
            return 1
        fi
    done
    
    echo $(basename $path)
}

alias ctl='systemctl --user'
alias jctl='journalctl --user'
