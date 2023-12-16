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

dnf install maven -y &>> $LOGFILE
VALIDATE $? "installing maven"
id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop 
    VALIDATE "$?" "roboshop user added"
else
    echo -e "$Y roboshop user already added $n"
fi    
mkdir -p /app &>> $LOGFILE
VALIDATE $? "directory app created"
curl -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE
VALIDATE $? "downloading roboshop zip file"
cd /app &>> $LOGFILE
VALIDATE $? "changing directory"
unzip -o /tmp/shipping.zip &>> $LOGFILE
VALIDATE $? "unzipping shipping.zip"
mvn clean package &>> $LOGFILE
VALIDATE $? "mavean package clean"
mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE
VALIDATE $? "moving jar file"
cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE
VALIDATE $? "coping shipping.service to specified place"
systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "deamon reload"
systemctl enable shipping &>> $LOGFILE
VALIDATE $? "enabling shipping"
systemctl start shipping &>> $LOGFILE
VALIDATE $? "starting shipping"
dnf install mysql -y &>> $LOGFILE
VALIDATE $? "installing mysql client server"
mysql -h mysql.kalidindi.cloud -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE
VALIDATE $? "loading shipping data" 
systemctl restart shipping &>> $LOGFILE
VALIDATE $? "restart shipping"





