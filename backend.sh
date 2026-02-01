#!/bin/bash
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
P="\e[35m"
C="\e[36m"
N="\e[0m"

USER_ID=$(id -u)
SCRIPT_DIR=$pwd 
LOG_FOLDER="/var/log/Expense-Project-LOGS"
LOG_FILE="$LOG_FOLDER/$0.log"
MYSQL_HOST="mysql.opsora.space"
password="ExpenseApp@1"

mkdir -p $LOG_FOLDER

if [ $USER_ID -ne 0 ]; then
   echo -e " $R User is not Root. Kindly run the script as Root user. $N "
   exit 1
fi

VALIDATE() {

if [ $1 -ne 0 ]; then
    echo -e " $R $2... Failed " | tee -a $LOG_FILE
else
    echo -e "$G $2... Success" | tee -a $LOG_FILE
fi 

}

dnf module disable nodejs -y &>> $LOG_FILE
VALIDATE $? "Disabling Default NodeJS"

dnf module enable nodejs:20 -y &>> $LOG_FILE
VALIDATE $? "Enabling Node js version 20."

dnf install nodejs -y &>> $LOG_FILE
VALIDATE $? "Installing Nodejs"

#Updating the openssl package to not break SSH Login

dnf update -y openssh openssh-server openssh-clients &>> $LOG_FILE
VALIDATE $? "Updating openssh package"

id expense 
if [ $? -ne 0 ]; then
  useradd --system --home /app --shell /sib/nologin --comment "expense system user" expense
else
   echo -e "$R User already present. $Y Hence, skipping the creaation of user. $N"
fi

mkdir -p /app &>> $LOG_FILE
VALIDATE $? "Creating app directory"

curl -o /tmp/backend.zip https://expense-joindevops.s3.us-east-1.amazonaws.com/expense-backend-v2.zip  &>> $LOG_FILE
VALIDATE $? "Downloading application code"

cd /app

unzip /tmp/backend.zip &>> $LOG_FILE


npm install &>> $LOG_FILE
VALIDATE $? "Installing Dependencies"

touch /etc/systemd/system/backend.service

cp $SCRIPT_DIR/backend.conf /etc/systemd/system/backend.service &>> $LOG_FILE


systemctl daemon-reload &>> $LOG_FILE
VALIDATE $? "Daemon Reload has been "
systemctl start backend
systemctl enable backend &>> $LOG_FILE



dnf install mysql -y &>> $LOG_FILE
VALIDATE $? "Installing mysql"

mysql -h $MYSQL_HOST -uroot -p${password} < /app/schema/backend.sql

VALIDATE $? "Loading Schema to root database"

systemctl restart backend
VALIDATE $? "Restarting backend service"