#! /usr/bin/env bash 

#########################################################################
# About: 	Force close ssh session for users after specific time	#
# Usage:	Change the "ses_tmo" and "minutes_to_warn" values to 	#
#		your own values.					#
#		Save the script somewhere in the system.		#
#									#
#		Make sure the script has executable permissions:	#
#		chmod +x /full/path/to/sript				#
#		Set a cron by opening the cronjob editor: crontab -e 	#
#									#
#		Add the cron to run it periodically. E.G.:		#
#		- run every 1 minute :   * * * * * /full/path/to/sript 	#
#  		- run every 5 minutes: */5 * * * * /full/path/to/sript	#
# Author: 	Marin Nedea <marin.nedea@microsoft.com>			#
#########################################################################
# Disclaimer:								#
#  		This script is provide "as it is", without any warranty.#
#		If you cause any damage to your system by using this 	#
#		script, this is solely your responsibility. Neither the #
#		script author or the company he/she works for should be #
#		held responsible for the results, wanted or unwanted, 	#
#		this script may create while being used.		#
#									#
#########################################################################					


# Set the session timout value in minutes
ses_tmo=15
minutes_to_warn=1

# Function to add date to log
add_date() {
    while IFS= read -r line; do
        echo "$(date) $line"
    done
}

# Location of temporary file to store the results and logfile 
temp_file=/tmp/temp_file_sessions
log_file=/var/log/terminated_ssh_sessions.log

# Get a list of active sessions, excluding root, grep and any line that includes []
ps -eo etimes,pid,cmd --sort=etimes | grep 'sshd\|@pts' | grep -v 'grep\|root\|[^[]]' | awk -F '@' '{print $1" "$2 }' | awk '{ print $1" "$2" "$4" "$5}'> $temp_file

while IFS='' read -r line || [[ -n "$line" ]]; do

        #Get the time elapsed since the session started, in seconds
        session_time=$(echo $line | awk '{print $1}')

        # Get the session PID
        session_pid=$(echo $line | awk '{print $2}')

        # Get the username
        user=$(echo $line | awk '{print $3}')

        # Get the PTS
        session_pts=$(echo $line | awk '{print $4}')

        # Transform the session_time in minutes
        min_passed=$[session_time/60]

		# Get the warning time
        warning_time=$[ses_tmo - min_passed]

        # Send a warning to user if 2 or less minutes are remaning.
        if [ "$warning_time" -le "$minutes_to_warn" ]; then   
				# Echo to user pts
                echo "Hello $user! Your session will expire and it will be closed automatically in less than $minutes_to_warn minute(s)! Save your work now!" > /dev/$session_pts              
                # Log the warning
		echo "$user has been warned that the session will exprire in less than $minutes_to_warn minute(s)" | add_date  >> $log_file
        fi

        # Compare the time passed since the session started with our session timeout value
        if [ "$min_passed" -ge "$ses_tmo" ]; then
                # Log the session kill
                echo "$user has been logged in for more than $ses_tmo minutes.Killing session for user $user" | add_date >> $log_file
                kill -9 $session_pid | add_date &>> $log_file
        else
                # Log the sessions that are yet under the time limit
		echo "$user has been logged in for $min_passed minutes and has not rached the $ses_tmo minutes allocated.Skiping!" | add_date >> $log_file
        fi

done < "$temp_file"
rm -rf $temp_file
