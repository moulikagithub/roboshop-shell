#!/bin/bash

id=$(id -u)
r="\e[31m"
g="\e[32m"
y="\e[33m"
n="\e[0m"
timestamp=$(date +F%-%H-%M-%S)
logfile="/tmp/$0-$timestamp.log"
echo "script started excuting at $logfile" &>>$logfile

validate(){
    if [ $1 -ne 0 ]
    then
        echo -e "$r Error:: $2 ....failed $n"
        exit 1
    else
        echo -e "$g $2....sucess"
    fi
}

if [ $id -ne 0 ]
then
     echo -e "$r Error::please login with root acess $n"
     exit 1
else
     echo -e "$g logged in with root user $n"
fi
dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>>$logfile

validate "$?" "installing Redis repo" 

 dnf module enable redis:remi-6.2 -y &>>$logfile

 validate "$?" "enabling Redis" 

dnf install redis -y &>>$logfile

validate "$?" "installing Redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>>$logfile

validate "$?" "updating listed address"

systemctl enable redis &>>$logfile

validate "$?" "enabling Redis"

systemctl start redis &>>$logfile

validate "$?" "starting Redis"


