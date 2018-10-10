# !/usr/bin/env bash

sleeptime=30
read -p 'Account name? ' acct 

# Building an array of logged in users
declare -a pids_array="$(ps -eo pid,cmd --sort=pid | grep "$acct" | grep '@pts'|  grep -v 'grep\|root' | awk -F 'sshd:|@' '{ print $1" "$3 }')"

printf '%s\n' "${pids_array[*]}" | while read line; do

   
        ses_pid="$(echo $line | awk '{print $1}')"
        ses_tty="$(echo $line | awk '{print $2}')"

        # warn the user he/she's about to be kicked out from the session in an interval
        # of 20 sec, starting 1 min 10 seconds and 50 seconds before the session timeout:
       
        echo "Hello $acct, your SSH session will be terminated in ~ $sleeptime sec! Save your work NOW!" > /dev/$ses_tty
       
        # If the timeout value we set is less or equal to the session duration, kill the pid
        sleep $sleeptime && kill -9 $ses_pid
done
