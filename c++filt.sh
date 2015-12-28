#########################################################################
# File Name:c++filt.sh
# Author: sudoku.huang
# mail: sudoku.huang@gmail.com
# Created Time:2015-12-18 17:14:07
#########################################################################

#! /bin/bash

U_ID=""
G_ID=""

function _whoami()  # get username & group
{
    local uid_gid=`id`

    gid=${uid_gid##*(}
    gid=${gid%)*}
  
    U_ID=`whoami`
    G_ID=$gid
    echo "UID:$U_ID, GID:$G_ID"
}

function get_permission() #arg like:-rwxr-xr-x
{
    local permission=$1
    local flag=$2  # 0-owner, 1-group, 2-other
    local op=$3    # r-read, w-write, x-execute

    local begin=1
    if [ $flag -eq 0 ]; then
        begin=2
    elif [ $flag -eq 1 ]; then
        begin=5
    elif [ $flag -eq 2 ]; then
        begin=8
    else
        return 0
    fi
    local end=$((begin+2))

    local check_op=""
    if [[ $op != ${op#r} ]]; then
        check_op=$check_op"r"
    fi
  
    if [[ $op != ${op#w} ]]; then
        check_op=$check_op"w"
    fi
  
    if [[ $op != ${op#x} ]]; then
        check_op=$check_op"x"
    fi
  
    local check=`echo $permission | cut -c$begin-$end`
    echo ${check#$check_op}
    if [[ $check == ${check#$check_op} ]]; then
        return 0
    else
        return 1
    fi
}

function check_permission() #file
{
    local filename=$1
    local permission_to_check=$2

    if [ -z $filename ]; then
        echo "check_permission, input empty arg"
        return 0;
    fi

    if [ -z $permission_to_check ]; then
        echo "check_permission, no permission to check"
        return 0;
    fi

    if [ ! -e $filename ]; then
        echo "check_permission, ($filename) not exists!"
        return 0;
    fi

    local out=`ls -l $filename`
    local permission=`echo $out | awk '{print $1}'`
    local owner=`echo $out | awk '{print $3}'`
    local group=`echo $out | awk '{print $4}'`
    #echo "permission:$permission, owner:$owner, group:$group"

    local ret=0
    if [[ $group == $G_ID ]]; then
        if [[ $owner == $U_ID ]]; then
            ret=$(get_permission $permission 0 "r")
        else
            ret=$(get_permission $permission 1 "r")
        fi
    else
        ret=$(get_permission $permission 2 "r")
    fi
    ret=$?
    #echo "permission:$ret"
    return $ret
}

function do_filt()
{
    echo "get all symbols, $1"
    check_permission $1 "r"
    local permission=$?
    echo "permission:$?"
    if [ $permission -gt 0 ]; then
        readelf -s $1 | while read line
        do
            local symbol=`echo $line | awk '{print $8}'`
            local s1=`echo $symbol | c++filt`
            echo  -e "$s1\t\t\t\t\t\t$symbol"
        done
    fi
}

function main()
{
    do_filt $*
}

main $*
