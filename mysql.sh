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

dnf module disable mysql -y &>> $logfile
validate $? "Disabling previous mysql version"
cp mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE
validate $? "coping mysql repos.."
dnf install mysql-community-server -y &>> $logfile
validate $? "installing mysql"
systemctl enable mysqld &>> $logfile
validate $? "enabling mysql.."
systemctl start mysqld &>> $logfile
validate $? "starting mysql"
mysql_secure_installation --set-root-pass RoboShop@1 &>> $logfile
validate $? "changed  password"
