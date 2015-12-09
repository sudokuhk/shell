#########################################################################
# File Name:set_limit.sh
# Author: sudoku.huang
# mail: sudoku.huang@gmail.com
# Created Time:Wed 09 Dec 2015 08:55:33 PM CST
#########################################################################
#!/bin/bash

f="0"
while getopts ":c:d:e:f:i:l:m:n:p:q:r:s:t:u:v:x" opt; do
    if [ "$f" == "1" ]; then
        echo "too many arguments" >&2;
        exit 1
    fi
    f="1"
    v="$OPTARG"
    case $opt in
        c) r=4  ;; # RLIMIT_CORE       core file size
        d) r=2  ;; # RLIMIT_DATA       data seg size  
        e) r=13 ;; # RLIMIT_NICE       scheduling priority 
        f) r=1  ;; # RLIMIT_FSIZE      file size
        i) r=11 ;; # RLIMIT_SIGPENDING pending signals
        l) r=8  ;; # RLIMIT_MEMLOCK    max locked memory
        m) r=5  ;; # RLIMIT_RSS        max memory size
        n) r=7  ;; # RLIMIT_NOFILE     open files
        q) r=12 ;; # RLIMIT_MSGQUEUE   POSIX message queues
        r) r=14 ;; # RLIMIT_RTPRIO     real-time priority
        s) r=3  ;; # RLIMIT_STACK      stack size
        t) r=0  ;; # RLIMIT_CPU        cpu time
        u) r=6  ;; # RLIMIT_NPROC      max user processes
        v) r=9  ;; # RLIMIT_AS         virtual memory
        x) r=10 ;; # RLIMIT_LOCKS      file locks

        ?) echo "bad argument $opt" >&2; exit 1 ;;
  esac
done

shift $(($OPTIND - 1))

if echo "$v" | grep -q -E "^\-?[0-9]+$"; then
    true
else
    echo "bad rlimti value $v" >&2
    exit 2
fi

if [ `echo "$v==-1 || ($v>=0 && $v<1048576)"|bc` == '0' ];then
    echo "bad rlimti value $v" >&2
    exit 2
fi

pid=$1
bin=`readlink /proc/$pid/exe`
if [ -z "$bin" ]; then
    echo "process $pid not found" >&2
    exit 3
fi

cmd='
set $rlim=&{-1ll,-1ll}
print getrlimit('$r',$rlim)
set *$rlim[0]='$v'
print setrlimit('$r',$rlim)
quit
'

result=`echo "$cmd" | gdb $bin $pid 2>/dev/null | grep '(gdb) \$2 ='`
result="${result##*= }"
exit $result

