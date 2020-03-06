#!/bin/bash

# install sshpass
sudo apt-get update
sudo apt-get install sshpass

## detect sender server or receive server
if [[ $1 == "-s" ]]; then 
	sender_server=0
elif [[ $1 == "-r" ]]; then
	receiver_server=0
else
	echo "请输入参数; -s表示脚本运行在旧服务器上，-r表示脚本运行在新服务器上"
fi

## code for sender server

# get IP and passwd; finally copy the database file to new server via ssh
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

## code for receiver server

if [[ ${receiver_server} == 0 ]]; then
	
	# install v2-ui
	sudo curl -Ls https://blog.sprov.xyz/v2-ui.sh | bash
	
	# change domain IP address
	domain="" #your domain name
	type_="A" 
	key="" #godaddy api key
	secret="" #godaddy api secret
	name="" #the name of record
	 
	headers="Authorization: sso-key $key:$secret"
	echo $headers
	
	result=$(curl -s -X GET -H "$headers" \
	"https://api.godaddy.com/v1/domains/$domain/records/$type_/$name")

	dnsIP=$(echo $result | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
	echo "dnsIP:" $dnsIP

	# Get public ip address
	ret=$(curl -s GET "http://ipinfo.io/json")
	currentIP=$(echo $ret | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
	echo "currentIP:" $currentIP

	curl -S -X PUT "https://api.godaddy.com/v1/domains/$domain/records/$type_/$name" \
	-H "accept: application/json" \
	-H "Content-Type: application/json" \
	-H "$headers" \
	-d "[ {\"data\": \"$currentIP\"} ]"

	# install Let's Encrypt and certification files
	sudo apt-get -y install socat
	sudo mkdir /etc/v2ray
	sudo curl https://get.acme.sh | sh
	sudo ~/.acme.sh/acme.sh --issue -d domainName --standalone -k ec-256
	sudo ~/.acme.sh/acme.sh --installcert -d domainName --fullchainpath /etc/v2ray/v2ray.crt --keypath /etc/v2ray/v2ray.key --ecc
	
fi

## debug
if [[ $sender_server == 0 ]]; then
	echo "sender_server=true"
elif [[ $receiver_server == 0 ]]; then
	echo "receiver_server=true"
fi
echo $1
