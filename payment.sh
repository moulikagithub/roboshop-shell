#!/bin/bash

ID=$(id -u)
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

if [ $ID -ne 0 ]
then
    echo -e "$y Error :: not an root user..run with root acess $n"
    exit 1
else
    echo -e "$y Logged in with root acess $n"
fi
dnf install python36 gcc python3-devel -y &>> $logfile
validate $? "installing python"
id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop 
    VALIDATE "$?" "roboshop user added"
else
    echo -e "$Y roboshop user already added $n"
fi    
mkdir -p /app &>> $logfile
 validate $? "making app directory"
curl -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $logfile
validate $? "Downloading roboshop"
cd /app &>> $logfile
validate $? "changing to app directory"
unzip -o /tmp/payment.zip &>> $logfile
validate $? "unzipping payment.zip"
pip3.6 install -r requirements.txt &>> $logfile
validate $? "installing dependencies"
cp /home/centos/roboshop-shell/payment.service /etc/systemd/system/payment.service &>> $logfile
validate $? "loading payment.service file"
systemctl daemon-reload &>> $logfile
validate $? "Daemon reload payment"
systemctl enable payment &>> $logfile
validate $? "enable payment"
systemctl start payment &>> $logfile
validate $? "starting payment"

