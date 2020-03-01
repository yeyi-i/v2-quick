#!/bin/bash

# install sshpass
sudo apt-get install sshpass

## detect sender server or receive server
if [[ $1 == "-s" ]]; then 
	sender_server=0
elif [[ $1 == "-r" ]]; then
	receiver_server=0
else
	echo "请输入参数; -s表示脚本运行在旧服务器上，-r表示脚本运行在新服务器上"
fi

## get IP and passwd
if [[ ${sender_server} == 0 ]]; then
	sender_ip=$2
	sender_passwd=$3
fi

## code for sender server
	
# get IP and passwd
if [[ ${sender_server} == 0 ]]; then
	if [[ $2 == "" ]]||[[ $3 == "" ]]; then
		echo "需要第二个参数：新服务器的IP
或第三个参数：新服务器的密码"
	else
		sender_ip=$2
		sender_passwd=$3
		if [[ -e "/etc/v2-ui/v2-ui.db" ]]; then
			sudo sshpass -p ${sender_passwd} -v scp -o StrictHostKeyChecking=no /etc/v2-ui/v2-ui.db ${sender_ip}:/etc/v2-ui/v2-ui.db
		else
          		echo "/etc/v2-ui/v2-ui.db 文件不存在"
 		fi
	fi
fi

# Install v2-ui
# echo "installing v2-ui"
# `sudo chmod +x ./v2-ui.sh`
# `sudo bash ./v2-ui.sh`
# echo "installed v2-ui"

## debug
if [[ $sender_server == 0 ]]; then
	echo "sender_server=true"
elif [[ $receiver_server == 0 ]]; then
	echo "receiver_server=true"
fi
echo $1