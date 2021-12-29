#! /bin/bash

###############################################################
# This script contains the Bash code portions commonly 
# used in other Yannek-JS Bash projects.
#
# Visit https://github.com/Yannek-JS/bash-scripts-lib
# for the most recent script release
############################################################### 

# the colours definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
LRED='\033[1;31m'
LGREEN='\033[1;32m'
YELLOW='\033[1;33m'
SC='\033[0m' # Standard colour


function draw_line() {  # it draws a line made of 80 hyphens
    for num in $(seq 0 79); do echo -n '-'; done
            echo
}


function quit_now { # displays nice message and quit the script
    echo -e ${BLUE}'\nI am quitting now. Have a nice day.'${YELLOW}' :-)\n'${SC}
        exit
}


function yes_or_not() {  # gives you a choice: to continue or to quit this script
#echo -e '\nIf you want to continue type '${LRED}'Yes'${SC}'. Otherwise type '{LGREEN}'No'${SC}'.'
    yn='no'
    while [[ ! "${yn,,}" == "yes" ]]
    do
        echo -e -n '\nIf you want to continue type '${LRED}'Yes'${SC}'. Otherwise type '${LGREEN}'No'${SC}': '
        read yn
        if [[ "${yn,,}" = "no" ]]; then quit_now; fi
    done
}


function check_if_root() {  # checks if script is being run by a user having root privileges
    if [ ! $(id -u) -eq 0 ]
    then
        echo -e ${ORANGE}'\nYou must have a root privileges to run this script !!!'${SC}
        quit_now
    fi
}

