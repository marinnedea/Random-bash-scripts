# !/usr/bin/env bash

# define session timeout in minutes
ses_timeout_min=15

# Doing the math for you and transforming our session timeout value in seconds
let ses_timeout_sec=ses_timeout_min*60

# Create an array with the active sessions details
declare -a ses_array="$(ps -eo etimes,pid,cmd --sort=etimes | grep '@pts' | grep -v 'grep\|root' | awk -F 'sshd:' '{ print $1 }')"

# Iterate through each line of the array
printf '%s\n' "${ses_array[*]}" | while read line; do

    ses_time="$(echo $line | awk '{print $1}')"
    ses_pid="$(echo $line | awk '{print $2}')"

    # If the timeout value we set is less or equal to the session duration, kill the PID
    (( $ses_time>=$ses_timeout_sec )) && kill -9 $ses_pid

done
