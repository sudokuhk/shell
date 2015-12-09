#! /bin/bash
path_host=config/hosts.conf
path_password=config/password.conf

# for line in `cat config/hosts.conf`
# while read line
# do
# echo $line
# done < $path_host
# echo "*********************"
# done

temp_num=`cat config/password.conf | awk '{print($NF)}' | wc -l`
echo "the password file lines : $temp_num"
temp_num2=`cat config/hosts.conf | awk '{print($NF)}' | wc -l`
echo "the userhost file lines : $temp_num2"
if [ $temp_num -ne $temp_num2 ]; then
    echo "please check the config file"
    exit;
fi

for ((i=1; i<=temp_num; i++)); do       
    password=`sed -n "${i}p" $path_password`
    userhost=`sed -n "${i}p" $path_host`
    #echo "**************************"
    echo ">>>>>login $userhost <<<<<" >> ./result.txt
    echo "**************************"
    #./sshpass -p $password ssh -o StrictHostKeyChecking=no $userhost "date" >> ./result.txt
    echo ">>>>>>>> Login remote $userhost OK <<<<<<<<"
done
