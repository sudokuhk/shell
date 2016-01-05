#########################################################################
# File Name:analyse_call_stack.sh
# Author: sudoku.huang
# mail: sudoku.huang@gmail.com
# Created Time:2016-01-05 14:58:22
#########################################################################
#./analyse_call_stack.sh -i __cyg_profile_func_enter -o __cyg_profile_func_exit -d call_stack.txt -s /home/whoami/git/mansions/test/a.out 

#! /bin/bash

VERSION="0.0.1"
SYMBOL_FILE=""
DUMP_FILE=""
ENTER_NAME=""
EXIT_NAME=""

function show_help()
{
    echo "Usage: sh analyse_call_stack.sh [-i|-o|-d|-s|-v]"
    echo "   -d            dump file, format: enter_name: called:addr caller:addr"
    echo "   -s            symbols file, must compile by -g"
    echo "   -i            enter function name"
    echo "   -o            exit funciton name"
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
            -i ) 
                ENTER_NAME=$2
                shift;shift;
                ;;
            -o )
                EXIT_NAME=$2
                shift;shift;
                ;;
            -d )
                DUMP_FILE=$2
                shift;shift;
                ;;
            -s )
                SYMBOL_FILE=$2
                shift;shift;
                ;;
            -v )
                echo "Version:$VERSION";
                echo "Copyright(@R):sudoku.huang@gmail.com";
                exit;
                ;;
            -h )
                show_help;
                exit;
                ;;
            * ) 
                echo "invalid option: $1"
                show_help;
                exit;
                ;;
        esac
    done
    return 1;
}

function check_arg()
{
    echo "ENTER_NAME:$ENTER_NAME, EXIT_NAME:$EXIT_NAME, DUMP_FILE:$DUMP_FILE, SYMBOL_FILE:$SYMBOL_FILE"
    if [ -z $ENTER_NAME ]; then
        echo "Please input enter function name!"
        return 0;
    fi

    if [ -z $EXIT_NAME ]; then
        echo "Please input exit function name!"
        return 0;
    fi

    if [ -z $DUMP_FILE ] || [ ! -f $DUMP_FILE ]; then
        echo "Please input dump file name!"
        return 0;
    fi

    if [ -z $SYMBOL_FILE ] || [ ! -f $SYMBOL_FILE ]; then
        echo "Please input symbol file name!"
        return 0;
    fi
    
    return 1;
}

function analyse()
{
    local enter_addr=""
    local exit_addr=""
    local flag=""
    local deep=""

    while read line
    do
        flag=`echo $line | awk '{print $1}'`
        enter_addr=`echo $line | awk '{print $2}'`
        exit_addr=`echo $line | awk '{print $3}'`
        
        if [[ $ENTER_NAME == $flag ]]; then
            enter_addr=${enter_addr##*=}
            exit_addr=${exit_addr##*=}
            enter_addr=`addr2line -e $SYMBOL_FILE -fp $enter_addr`
            echo -e "$deep $enter_addr"
            deep="$deep    "
        else
            local len=${#deep}
            deep=${deep:0:$len-4}
        fi
    done<$DUMP_FILE
}

function main()
{
    local ret=0;

    parse_arg $*;
    check_arg;
    ret=$?
    if [ $ret -eq 0 ]; then
        exit;
    fi

    analyse;
}

main $*
