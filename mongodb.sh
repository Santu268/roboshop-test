#!/bin/bash
LOG_PATH=/var/log/roboshop
sudo mkdir -p "$LOG_PATH"
sudo chmod -R 755 "$LOG_PATH"
LOG_FILE=$LOG_PATH/$(basename "$0").log
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
R='\e[31m' # Red
G='\e[32m' # Green
Y='\e[33m' # Yellow
N='\e[0m'  # No Color
USER_ID=$(id -u)

if [ "$USER_ID" -ne 0 ]; then
  echo -e "$TIMESTAMP [ERROR] ${R}You should run this script as root user or with sudo privileges${N}"
  exit 1
else
  echo -e "$TIMESTAMP [INFO] ${G}Running the script with root user privileges${N}" | tee -a "$LOG_FILE"
fi

validate() {
  if [ "$1" -ne 0 ]; then
    echo -e "$TIMESTAMP [ERROR] $2..${R} Failed to execute the command. Check the log file for details: $LOG_FILE${N}"
    exit 1
  else
    echo -e "$TIMESTAMP [INFO] $2..${G}Command executed successfully${N}" | tee -a "$LOG_FILE"
  fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> "$LOG_FILE"
validate $? "Adding MongoDB repository"

dnf install -y mongodb-org &>> "$LOG_FILE"
validate $? "Installing MongoDB"

systemctl enable mongod &>> "$LOG_FILE"
validate $? "Enabling MongoDB service"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
validate $? "Allowing remote connections to MongoDB"

systemctl start mongod &>> "$LOG_FILE"
validate $? "Starting MongoDB service"
