#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGDB_HOST=mongodb.kalidindi.cloud

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script stareted executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILED $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1 # you can give other than 0
else
    echo "You are root user"
fi
dnf module disable nodejs -y &>> $LOGFILE
VALIDATE "$?" "Disabling nodejs" 
dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE "$?" "enabling nodejs" 
dnf install nodejs -y &>> $LOGFILE
VALIDATE "$?" "installing nodejs" 
id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop 
    VALIDATE "$?" "roboshop user added"
else
    echo -e "$Y roboshop user already added $n"
fi    
mkdir -p /app &>> $LOGFILE
VALIDATE "$?" "creating app directory"
curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE
VALIDATE "$?" "Downloading roboshop zip file"
cd /app &>> $LOGFILE
VALIDATE "$?" "changing to app"
unzip -o /tmp/user.zip &>> $LOGFILE
VALIDATE "$?" "unzipping user.zip"
npm install &>> $LOGFILE
VALIDATE "$?" "installing nodejs packages"
cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service &>> $LOGFILE
VALIDATE "$?" "coping user.service"
systemctl daemon-reload &>> $LOGFILE
VALIDATE "$?" "daemon reload user"
systemctl enable user &>> $LOGFILE
VALIDATE "$?" "enabling user" 
systemctl start user &>> $LOGFILE
VALIDATE "$?" "starting user"
cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE "$?" "coping mongodb repo"
dnf install mongodb-org-shell -y &>> $LOGFILE
VALIDATE "$?" "installing mongodb client"
mongo --host mongodb.kalidindi.cloud </app/schema/user.js &>> $LOGFILE
