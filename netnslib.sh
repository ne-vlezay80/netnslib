#!/bin/bash

name2netns_dilimiter="."

assert () {
        echo "ASSERT!!!"
        exit 6
}

name2netns () {
        local str=$1
        local dlim=$name2netns_dilimiter
        local a

        if [[ -z "$dlim" ]]; then
                dlim="."
        fi

        local IFS=${dlim}
        local c=0

        for a in $str; do
                if [[ $c == 0 ]]; then
                        local svc=$a
                fi
                if [[ $c == 1 ]]; then
                        local ns=$a
                fi
                c=$((${c}+1))
        done

        if [[ $svc == $ns ]]; then
                assert
        fi

        SERVICE_NAME=${svc}
        NETNS=${ns}
        return 0
}


remove_ns () {

        # args: nsname

        local nsname=$1

        if [[ -z "$nname" ]]; then 
                return 1
        fi 

       if [[ ! -f /run/netns/${nsname} ]]; then
                return 127
        fi

        local a
        for a in $(ip netns exec ${nsname} ls /sys/class/net); do
                if ip netns exec ${nsname} [[ -d /sys/class/net/${a}/device ]]; then
                        if ip -n ${nsname} link set dev $a netns 1; then
                                continue
                        else
                                echo "ERROR: Moving interface failed."
                                return 1
                        fi
                fi
        done
        ip netns del ${nsname}
}
