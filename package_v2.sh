#! /bin/bash

VERSION="0.0.1"
DATE=""
TIME=""
OUTPUT=""
ZIPPARAM="zcvf"
ZIP_FILE_SUFFIX=".tar.gz"
PATHS=()
TAR_FILE_LIST=""
PIPE_NAME=`date +"%Y%m%d%H%M%S%N"`
PIPE_NAME=/tmp/_package_sh_$PIPE_NAME


function show_help()
{
    echo "Usage: sh package.sh [-d|-t|-p|-h|-v|-z] command parameters"
    echo "   -d            date "
    echo "   -t            time "
    echo "   -p            files in path that need to be tar."
    echo "   -o            output file name, maybe like test, output filename would be test.tar.bz2"
    echo "   -z            b-bzip, g-gzip"
    echo "   -h            Show help (this screen)"
    echo "   -v            Print version information"
}

function parse_arg()
{
    while true; do
        if [ $# -eq 0 ]; then
            break;
        fi

        case $1 in
            -t ) 
                TIME=$2
                shift;shift;
                ;;
            -z ) 
                local zip=$2
                if [ ! -z $zip ]; then
                    if [[ $zip == "b" ]]; then
                        ZIPPARAM="jcvf"
                        ZIP_FILE_SUFFIX=".tar.bz2"
                    fi 
                fi
                shift;shift;
                ;;
            -d )
                DATE=$2
                shift;shift;
                ;;
            -p )
                local p=($2)
                PATHS+=("${p[@]}")
                shift;shift;
                ;;
            -o )
                OUTPUT=$2; 
                shift;shift;
                ;;
            -v )
                echo "Version:$VERSION";
                exit;
                ;;
            -h )
                show_help;
                exit;
                ;;
            -- ) 
                shift; 
                ;;
            * ) 
                shift
                ;;
        esac
    done
    return 1;
}

function check_args()
{
    local date=$1
    local ttime=$2
    local output=$3
    local paths=$4

    if [ -z $date ] || [ -z $ttime ]; then
        echo "Please input date & time!"
        return 0;
    fi

    local res=`echo $date | grep "^[0-9]\{4,4\}-[0-9]\{2,2\}-[0-9]\{2,2\}"`
    if [ -z $res ]; then
        echo "Date format invalid! check!, date{$date}"
        return 0; 
    fi

    res=`echo $ttime | grep "^[0-9]\{2,2\}:[0-9]\{2,2\}:[0-9]\{2,2\}"`
    if [ -z $res ]; then
        echo "Time format invalid! check!, time{$ttime}"
        return 0; 
    fi

    if [ -z $output ]; then
        echo "Output file name empty, check it!"
        return 0;
    fi

    local num=${#PATHS[@]};
    if [ $num -eq 0 ]; then
        echo "Please input directory!"
        return 0;
    fi

    for path in ${PATHS[@]}
    do
        #echo "path...: $path"
        if [ ! -d $path ]; then
            echo "Input path argument:[$path] not directory!"
            return 0;
        fi
    done

    return 1;
}

function compare_time_v1()
{
    local datetime=$1
    local filename=$2

    local var=`ls $filename --full-time | grep "^-"`
    local t=`echo $var | awk '{print $5 $6}'` 
    local slen=${#datetime}
    var=${t:0:$slen}
    #echo "datetime:$datetime, filetime:$var"

    if [[ $var > $datetime ]]; then
        return 1;
    else
        return 0;
    fi
}

function compare_time_v2()
{
    local datetime=$1
    local filetime=$7$8

    local slen=${#datetime}
    var=${filetime:0:$slen}
    #echo "datetime:$datetime, filetime:$var"

    if [[ $var > $datetime ]]; then
        return 1;
    else
        return 0;
    fi
}

function read_pipe()
{
    while true
    do
        read line <&6
        if [[ $line == "end" ]]; then
            break;
        fi
        local pfile=($line)
        TAR_FILE_LIST+=("${pfile[@]}")
    done
}

function create_pipe()
{
    local pipename=$1
    echo "PIPE:"$pipename

    mkfifo $PIPE_NAME
    exec 6<>$PIPE_NAME
    rm -rf $PIPE_NAME
}

function do_handle()
{
    local output=$1;
    local dat=$2;
    local tim=$3;
    local paths=$4;
    local datetime="$2$3"

    create_pipe $PIPE_NAME

    for path in ${PATHS[@]}
    do
        find $path ! -type d -exec ls --full-time '{}' \; >&6
        echo "end" >&6

        while read line
        do
            if [[ $line == "end" ]]; then
                break;
            fi
            compare_time_v2 $datetime $line
            local ret=$?
            if [ $ret -gt 0 ]; then
                local filename=`echo $line | awk '{print $9}'`
                local pfile=($filename)
                TAR_FILE_LIST+=("${pfile[@]}")
            fi
        done <&6
    done 
    exec 6<&-
}

function main()
{
    local ret=1
    parse_arg $*

    check_args $DATE $TIME $OUTPUT $PATHS
    ret=$?
    if [ $ret -eq 0 ]; then
        show_help;
        exit;
    fi 

    do_handle $OUTPUT $DATE $TIME $PATHS
    #echo ${TAR_FILE_LIST[*]} 
    tar $ZIPPARAM $OUTPUT$ZIP_FILE_SUFFIX ${TAR_FILE_LIST[*]} 
}

main $*
