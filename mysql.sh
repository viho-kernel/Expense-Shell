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

dnf install mysql-server -y &>> $LOG_FILE

VALIDATE $? "Installing MySQL Server"

systemctl enable mysqld &>> $LOG_FILE

systemctl start mysqld &>> $LOG_FILE

VALIDATE $? "Starting and enable MySQL Server"

mysql_secure_installation --set-root-pass ExpenseApp@1

VALIDATE $? "Root user password setup"

