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
fi # fi means reverse of if, indicating condition end
dnf install nginx -y &>> $LOGFILE
VALIDATE $? "installing nginx"
systemctl enable nginx &>> $LOGFILE
VALIDATE $? "enabling nginx"
systemctl start nginx &>> $LOGFILE
VALIDATE $? "starting nginx"
rm -rf /usr/share/nginx/html/* &>> $LOGFILE
VALIDATE $? "removing unwanted content in html file"
curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE
VALIDATE $? "Downloading roboshop web"
cd /usr/share/nginx/html &>> $LOGFILE
VALIDATE $? "changing directory and opening file"
unzip -o /tmp/web.zip &>> $LOGFILE
VALIDATE $? "unzipping web.zip"
cp /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $LOGFILE
VALIDATE $? "coping roboshop.conf"
systemctl restart nginx &>> $LOGFILE
VALIDATE $? "restart nginx" 
