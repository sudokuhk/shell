#! /bin/sh

if [ $# -lt 2 ]; then
    echo "sample: ./statistics log.txt UIS_insert_res_len"
    exit
fi

fileName=$1 #first param is filename
match_str=$2  #match str
left="["
right="]"
total=0

echo $fileName $match_str

while read LINE
do
    substr=${LINE##*$match_str}  # find matchstr
    substr=${substr%%\]*}        #
    substr=${substr#*\[}
    total=$(($total + $substr))
done < $fileName 

echo "total = "$total
