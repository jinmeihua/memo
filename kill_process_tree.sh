if [ $# -ne 1 ]
then
    echo -e "Usage: sh kill_process_tree.sh <pid>" 
    exit 
fi

function killtree() {

    local pid=$1
    kill -stop ${pid}

    for child_pid in $(ps -o pid --no-headers --ppid ${pid});
    do
        killtree ${child_pid} 
    done

    kill -9 ${pid}
    echo "kill -9 ${pid}"
}

killtree $1
