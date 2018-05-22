#!/usr/bin/env bash
#script to add a user to Linux system

# check if you are root
if [ $(id -u) -eq 0 ]; then
        # Ask for the username
        read -p "Enter username : " username
        # check if we need to have a /home/$username directory
        read -p "Should we create a /home/$username directory? (y/n) " addhome
        [ $addhome = 'y' ] && createhome="-m" || createhome=""
        # Ask for password ( use -s to hide the text being typed )
        read -s -p "Enter password : " password
        # Check if user exists ( returns 0 if exists, 1 if does not exists )
        id -u $user > /dev/null 2>&1
        # if the username doesn't exists already
        if [ $? -eq 1 ] ; then
                # encrypt the password
                pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
                # create the username account
                useradd $createhome -p $pass $username
                [ $? -eq 0 ] && echo "User has been added to system!"; exit 0  || echo "Failed to add a user!"
        else
        # If username exists
                echo "$username exists!"
                exit 1
        fi
else
# If you are not root
        echo "Only root may add a user to the system"
        exit 2
fi
