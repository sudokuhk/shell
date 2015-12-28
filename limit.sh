#########################################################################
# File Name:limit.sh
# Author: sudoku.huang
# mail: sudoku.huang@gmail.com
# Created Time:Sat 12 Dec 2015 11:05:07 AM CST
#########################################################################
#!/bin/bash

ulimit -a | grep stack
stacksize=`ulimit -a | grep stack | grep unlimited | awk '{print $5}'`
if [ -z $stacksize ]; then
    echo "limit stacksize"
    ulimit -s unlimited
else
    echo "unlimit stacksize"
    ulimit -s 1073741824  #1T, 1024 * 1024 * 1024K
fi 

ulimit -a | grep stack
