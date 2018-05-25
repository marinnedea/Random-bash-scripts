#!/usr/bin/env bash


# Functions to be called by each option

#Create a new account new account
newaccount()
{
echo "Add a new user: "
while read -p 'Please enter the name of the user: ' user_name ; do
 	id -u $user_name > /dev/null 2>&1
        # If the username doesn't exists
        if [ $? -eq 1 ] ; then
        	break
		
        else
        # If username exists
                echo "$user_name exists!"
                
	fi
    done

read -p 'Do you need to add the user to any other group? Type the group name. If more than one, separate them by a coma: ' groupsarr
read -s -p "Enter password : " upass 
[[ ! -z $upass ]] &&  pass=$(perl -e 'print crypt($ARGV[0], "upass")' $upass) || echo 'Your public key has been saved.'

# Check if we need to have a /home/$username directory
echo ""
read -p "Should we create a /home/$user_name directory? y/n " addhome

[[ "$addhome" = "y" ]] && createhome="-m" || createhome=""

# Create the user
useradd $createhome -p $pass $user_name -s /bin/bash -G $groupsarr

[ $? -eq 0 ] && echo "User $user_name has been added to system!" || echo "Failed to add a user!"; exit 1

}

# Delete an account
delaccount(){
read -p "Should we list all the users in the system? y/n " listusers

# Listing all non-system accounts
[[ $listusers == "y" ]] && awk -F: '($3>=1000)&&($1!="nobody"){print $1}' /etc/passwd || echo "OK, I hope you already know the username to delete!"

#echo "Remove an user: "
while read -p 'Please enter the name of the user: ' user_name ; do
        id -u $user_name > /dev/null 2>&1
        # If the username doesn't exists
        if [ $? -eq 1 ] ; then
               echo "There's no such username in the system!"

        else
        # If username exists
                break

        fi
done
[ -d /home/$user_name ] && read -p "Do you want to delete the user home directory? y/n: " delhome 

[[ ! -z $delhome ]] && delhomeconf="--remove" || delhomeconf=""

read -p "Are you sure? y/n:  " confirm
[[ $confirm == "y" ]] && userdel -f $delhomeconf $user_name || echo "$user_name was not deleted."

}

# Modify account

modifaccount(){ 
read -p "Should we list all the users in the system? y/n " listusers

# Listing all non-system accounts
[[ $listusers == "y" ]] && awk -F: '($3>=1000)&&($1!="nobody"){print $1}' /etc/passwd || echo "OK, I hope you already know the username to modify!"

echo "Type the name of the user to modify: "
while read -p 'Please enter the name of the user: ' user_name ; do
        id -u $user_name > /dev/null 2>&1
        # If the username doesn't exists
        if [ $? -eq 1 ] ; then
               echo "There's no such username in the system!"

        else
        # If username exists
                break

        fi
done

prompt='Please select your action: '
options=("Change pasword" "Lock account" "Unlock account" "Set password expire date" "Change the shell" "Add user to a new group")

echo "$title"
PS3="$prompt "
select opt in "${options[@]}" "Quit"; do

    case "$REPLY" in

    1 ) passwd $user_name ;;
    2 ) usermod -s /usr/sbin/nologin $user_name ;;
    3 ) usermod -s /bin/bash $user_name ;;
    4 ) cdate="$(date)" 
	echo "Current date is: $cdate"
	read -p "when do you want the $user_name password to expire? YYYY-MM-DD" passexp
	usermod -e $passexp $user_name 
	;;
    5 ) read -p "Type the group name. For multiple groups, just separate the entries with a coma: "  groupsarr
	usermod -G $groupsarr $user_name
	;;
    $(( ${#options[@]}+1 )) ) echo "Goodbye!"; break;;
    *) echo "Invalid option. Try another one.";continue;;

    esac

done
}

# Show the menu 
title='Welcome to the User Management Application'
prompt='Please select your action: '
options=("Add a new user" "Delete an user" "Modify an existing user")

echo "$title"
PS3="$prompt "
select opt in "${options[@]}" "Quit"; do

    case "$REPLY" in

    1 ) newaccount ;;
    2 ) delaccount ;; 
    3 ) modifaccount ;;

    $(( ${#options[@]}+1 )) ) echo "Goodbye!"; break;;
    *) echo "Invalid option. Try another one.";continue;;

    esac

done


while opt=$(zenity --title="$title" --text="$prompt" --list \
                   --column="Options" "${options[@]}"); do

    case "$opt" in
    "${options[0]}" ) zenity --info --text="You picked $opt, option 1";;
    "${options[1]}" ) zenity --info --text="You picked $opt, option 2";;
    "${options[2]}" ) zenity --info --text="You picked $opt, option 3";;
    *) zenity --error --text="Invalid option. Try another one.";;
    esac

done
