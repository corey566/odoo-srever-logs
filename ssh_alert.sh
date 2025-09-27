#!/bin/bash
tail -F /var/log/auth.log | grep --line-buffered "Accepted password\|Accepted publickey" | while read line; do
  echo "SSH Login Alert: $line" | mail -s "SSH Login Alert" noreply@codestudio.lk
done
