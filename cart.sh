#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


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
curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE
VALIDATE "$?" "Downloading roboshop zip file"
cd /app &>> $LOGFILE
VALIDATE "$?" "changing to app"
unzip -o /tmp/cart.zip &>> $LOGFILE
VALIDATE "$?" "unzipping cart.zip"
npm install &>> $LOGFILE
VALIDATE "$?" "installing nodejs packages"
cp /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service &>> $LOGFILE
VALIDATE "$?" "coping cart.service"
systemctl daemon-reload &>> $LOGFILE
VALIDATE "$?" "daemon reload cart"
systemctl enable cart &>> $LOGFILE
VALIDATE "$?" "enabling cart" 
systemctl start cart &>> $LOGFILE
VALIDATE "$?" "starting cart"

