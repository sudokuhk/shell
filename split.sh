#########################################################################
# File Name:split.sh
# Author: sudoku.huang
# mail: sudoku.huang@gmail.com
# Created Time:Sat 24 Oct 2015 02:42:30 PM CST
#########################################################################
#!/bin/bash

user="mark:x:0:0:this is a test user:/var/mark:nologin"
i=1
while((1==1))
do
    split=`echo $user|cut -d ":" -f$i`
    if [ "$split" != "" ]
    then
        ((i++))
        echo $split
    else
        break
    fi
done
