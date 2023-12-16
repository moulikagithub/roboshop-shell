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
dnf install golang -y &>> $LOGFILE
VALIDATE $? "installing golang"
id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop 
    VALIDATE $? "roboshop user is creation"
else
    echo -e "$Y roboshop user already added $n"
fi    
mkdir -p /app &>> $LOGFILE
VALIDATE $? "making app directory"
curl -o /tmp/dispatch.zip https://roboshop-builds.s3.amazonaws.com/dispatch.zip &>> $LOGFILE
VALIDATE $? "downloading roboshop"
cd /app &>> $LOGFILE
VALIDATE $? "changing to app directory"
unzip -o /tmp/dispatch.zip &>> $LOGFILE
VALIDATE $? "unzipping dispatch file"
go mod init dispatch &>> $LOGFILE
VALIDATE $? "installing dependencies1"
go get &>> $LOGFILE 
VALIDATE $? "installing dependencies2"
go build &>> $LOGFILE
VALIDATE $? "installing dependencies3"
cp /home/centos/roboshop-shell/dispatch.service /etc/systemd/system/dispatch.service &>> $LOGFILE
VALIDATE $? "loading dispatch services"
systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "daemon-reloading"
systemctl enable dispatch &>> $LOGFILE
VALIDATE $? "enable dispatch"
systemctl start dispatch &>> $LOGFILE
VALIDATE $? "starting dispatch"