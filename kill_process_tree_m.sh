#Usage: kill_process_tree <root_pid>
function kill_process_tree()
{
    if [ $# -ne 1 ]
    then
        echo -e "Usage: kill_process_tree <root_pid>"
        return
    fi

    local father=$1

    # children
    childs=(`ps jf | awk -v father=$father 'BEGIN{ ORS=" "; } $1==father{ print $2; }' `)
    if [ ${#childs[@]} -ne 0 ]
    then
        for child in ${childs[*]}
        do
            kill_process_tree $child
        done
    fi

    # father
    echo -e "kill pid $father"
    kill -9 $father
}
