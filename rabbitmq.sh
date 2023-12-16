#!/bin/bash

id=$(id -u)
timestamp=$(date +%F-%H-%M-%S)
logfile="/tmp/$0-$timestamp.log"
r="\e[31m"
g="\e[32m"
n="\e[0m"
y="\e[33m"

echo "script started excuting at: $timestamp" &>> $logfile

validate(){
   if [ $1 -ne 0 ] 
   then
        echo -e "$r Error:: $2 is failed $n"
        exit 1
        
   else
        echo -e "$2......is $g success $n"
    fi           
} 

if [ $id -ne 0 ]
then
    echo -e "$y Error :: not an root user..run with root acess $n"
    exit 1
else
    echo -e "$y Logged in with root acess $n"
fi
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>> $logfile
validate $? "configuring erlang"
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> $logfile
validate $? "configuring yum repo"
dnf install rabbitmq-server -y &>> $logfile
validate $? "installing rabbitmq"
systemctl enable rabbitmq-server &>> $logfile
validate $? "enabling rabbitmq"
systemctl start rabbitmq-server &>> $logfile
validate $? "start rabbitmq"
rabbitmqctl add_user roboshop roboshop123 &>> $logfile
validate $? "setting password to roboshop"
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $logfile
validate $? "setting permissions"