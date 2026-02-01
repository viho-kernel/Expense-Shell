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

dnf install nginx -y  &>> $LOG_FILE

VALIDATE $? "Installing nginx"

systemctl enable nginx &>> $LOG_FILE

VALIDATE $? "Enabling Nginx"

systemctl start nginx &>> $LOG_FILE
VALIDATE $? "Starting Nginx"

rm -rf /usr/share/nginx/html/* &>> $LOG_FILE
VALIDATE $? "Removing Default Nginx server"

curl -o /tmp/frontend.zip https://expense-joindevops.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>> $LOG_FILE
VALIDATE $? "Installing cODE"

cd /usr/share/nginx/html

unzip /tmp/frontend.zip &>> $LOG_FILE
VALIDATE $? "Unzipping the code."


cp $SCRIPT_DIR/frontend.conf /etc/nginx/default.d/expense.conf
VALIDATE $? "Copying the code."

systemctl restart nginx &>> $LOG_FILE
VALIDATE $? "Restarting Nginx Service"

