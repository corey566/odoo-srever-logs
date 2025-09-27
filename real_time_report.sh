#!/bin/bash
LOG_DIR="/var/log/server_monitor"
EMAIL="noreply@codestudio.lk"
REPORT_FILE="$LOG_DIR/server_live_$(date +%F_%H%M%S).txt"

echo "===== Active SSH Sessions =====" > $REPORT_FILE
who >> $REPORT_FILE

echo -e "\n===== Active Ports =====" >> $REPORT_FILE
ss -tulnp >> $REPORT_FILE

echo -e "\n===== Docker Containers =====" >> $REPORT_FILE
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" >> $REPORT_FILE

echo -e "\n===== Postgres Databases =====" >> $REPORT_FILE
sudo -u postgres psql -c "\l" >> $REPORT_FILE

echo -e "\n===== Network Connections =====" >> $REPORT_FILE
netstat -tunp >> $REPORT_FILE

echo -e "\n===== Auditd System Changes =====" >> $REPORT_FILE
ausearch -k system_changes --format text >> $REPORT_FILE
ausearch -k ssh_logins --format text >> $REPORT_FILE
ausearch -k docker_changes --format text >> $REPORT_FILE
ausearch -k postgres_changes --format text >> $REPORT_FILE

echo -e "\n===== AIDE File Integrity =====" >> $REPORT_FILE
aide --check >> $REPORT_FILE

# Email alert
mail -s "Server Live Report $(date +%F_%H:%M)" $EMAIL < $REPORT_FILE

# Push to GitHub
cd $LOG_DIR
git add .
git commit -m "Live report $(date +%F_%H:%M)"
git push origin master
