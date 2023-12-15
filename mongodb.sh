#!/bin/bash

id=$(id -u)
timestamp=$(date +%F-%H-%M-%S)
log_file="/tmp/$0-$timestamp.log"
r="\e[31m"
g="\e[32m"
n="\e[0m"
y="\e[33m"

echo "script started excuting at: $timestamp" &>> $log_file

validate(){
   if [ $1 -ne 0 ] 
   then
        echo -e "$r Error:: $2 is failed $n"
        
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
cp mongo.repo /etc/yum.repos.d &>> $log_file
validate "$?" "$g coping mongo.repo.."
dnf install mongodb-org -y &>> $log_file
validate "$?" "installing mongodb.."
systemctl enable mongod &>> $log_file
validate "$?" "enabling mongodb.."
systemctl start mongod &>> $log_file
validate "$?" "starting mongodb.."
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $log_file
validate "$?" "updated mongod.conf.."
systemctl restart mongod &>> $log_file
validate "$?" "mongodb restart.."
 
