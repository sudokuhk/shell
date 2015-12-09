#########################################################################
# File Name:path.sh
# Author: sudoku.huang
# mail: sudoku.huang@gmail.com
# Created Time:Fri 23 Oct 2015 04:24:23 PM CST
#########################################################################
#!/bin/bash

path="HOME/sh/tmp"
echo $path
path="$"$path
echo $path

# ok
echo "---2---"
cmd="cd $path"
echo $cmd
eval $cmd
pwd
cd -
echo "-------"

echo "----3-----"
echo $path
if [ -d $path ]; then
    echo "path:$path"
else
    echo "not path!"
fi

sed -i -e 's/"//g' $$path
cd $path
