#########################################################################
# File Name:for.sh
# Author: sudoku.huang
# mail: sudoku.huang@gmail.com
# Created Time:2015-12-19 10:21:36
#########################################################################

#! /bin/bash

array=(element1 element2 element3 .... elementN)
echo ${array[0]}

for data in ${array[@]}  
do  
    echo ${data}  
done 
for arobj in atexit.o crt1.o crtn.o entry.o malloc.o printf.o stdio.o string.o crtbegin.o crtend.o ctors.o iostream.o new_delete.o stringcxx.o sysdep.o 
do 
    echo obj:$arobj 
done
