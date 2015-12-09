#########################################################################
# File Name:create_huge_empty_files.sh
# Author: sudoku.huang
# mail: sudoku.huang@gmail.com
# Created Time:Fri 30 Oct 2015 04:08:26 PM CST
#########################################################################
#!/bin/bash

echo $#
if [ $# -ne 2 ]; then
    echo "input filepaht filenumber"
    exit
fi

path=$1
iNumbers=$2

if [ ! -e $path ] && [ ! -d $path ]; then
    echo "input a valid path!:" $path
    exit
fi

echo "numbers = "$iNumbers
echo "path    = "$path

path_pre=d
file_pre=f
for ((i = 0; i < iNumbers; i++)); do
    filename=$file_pre$i
    echo $filename
done
