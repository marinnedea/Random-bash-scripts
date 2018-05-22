#!/usr/bin/env bash
# Add a user to Linux system

# Check if you are root
if [ $(id -u) -eq 0 ]; then
        # Ask for the username
        read -p "Enter username : " username
        # Check if we need to have a /home/$username directory
        read -p "Should we create a /home/$username directory? (y/n) " addhome
        [ $addhome = 'y' ] && createhome="-m" || createhome=""
        # Ask for password ( use -s to hide the text being typed )
        read -s -p "Enter password : " password
        # Check if username exists (returns 0 if exists, 1 if it doesn't exists)
        id -u $user > /dev/null 2>&1
        # If the username doesn't exists
        if [ $? -eq 1 ] ; then
                # Encrypt the password
                pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
                # Create the username account
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
