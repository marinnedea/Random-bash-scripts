# !/usr/bin/env bash

# define session timeout in seconds
ses_timeout_min=15

# Doing dome math
let ses_timeout_sec=ses_timeout_min*60
let warning_time_min=ses_timeout_sec-70
let warning_time_max=ses_timeout_sec-50

# Building an array of logged in users
declare -a ses_array="$(ps -eo etimes,pid,cmd --sort=etimes | grep '@pts' | grep -v 'grep\|root' | awk -F 'sshd:|@' '{ print $1" "$2" "$3 }')"

printf '%s\n' "${ses_array[*]}" | while read line; do

        ses_time="$(echo $line | awk '{print $1}')"
        ses_pid="$(echo $line | awk '{print $2}')"
        ses_user="$(echo $line | awk '{print $3}')"
        ses_tty="$(echo $line | awk '{print $4}')"

        # warn the user he/she's about to be kicked out from the session in an interval
        # of 20 sec, starting 1 min 10 seconds and 50 seconds before the session timeout:
       
        (( $ses_time>=$warning_time_min && $ses_time<=$warning_time_max )) && echo "Hello $ses_user. Your SSH session will be terminated in ~ 1 min. Save your work NOW!" > /dev/$ses_tty
       
        # If the timeout value we set is less or equal to the session duration, kill the pid
        (( $ses_time>=$ses_timeout_sec )) && kill -9 $ses_pid
done
