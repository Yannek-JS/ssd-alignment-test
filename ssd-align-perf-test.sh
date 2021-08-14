#! /bin/bash

# Thanks to this script you can test a writing performance to a disk (SSD) with different partition alignment settings stored in JSON config file.
# For more information check README.md file

# the colours definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
LRED='\033[1;31m'
LGREEN='\033[1;32m'
YELLOW='\033[1;33m'
SC='\033[0m' # Standard colour

scriptPath=$(dirname $(realpath $0))    # full path to the directory where the script is located

CONFIGFILE=$scriptPath'/config/script-params.json'  # parameters for parted command for consecutive alignments tests

blkDevPath=''   # a block device path of the device selected for the alignment test
declare -a blkDevList   # an array of block devices available at the moment


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


function preconfig() {  # gets params for parted command from $CONFIGFILE
    # read some parameters to make all the process more automatic
    if [ -f $CONFIGFILE ]
    then
        scriptConfig=$(<$CONFIGFILE)
        jq -er '.' <<< $scriptConfig 1>/dev/null 2> $scriptPath'/log/jq_error.log'  # write an error into log/jq_error.log file. If there is no error, it creates an empty file
        if ! [ $? -eq 0 ]   # controls whether syntax of $CONFIGFILE is correct for jq
        then
            echo -e "\n${LRED}The config file ${BLUE} $CONFIGFILE ${LRED} is incorrectly formatted. Correct all the errors and run the script again.${SC}"
            echo -e '\nYou may find it helpful to check '${BLUE}$scriptPath'/log/jq_error.log'${SC}' file content.'
            quit_now
        fi
    else
        echo -e ${LRED}'\nThe config file '${BLUE} $CONFIGFILE ${LRED}'is missing.'
        quit_now
    fi
}


function select_blk_dev_menu() {    # displays a menu for block device selection
    clear
    echo 'This script tests a writing performance to a selected disk with the partition alignment settings stored in a JSON config file.'
    echo -e ${ORANGE}'\n!!! WARNING !!!'
    echo -e 'Be careful !!! By mistake you may loose your data !!! You are using this script on your own responsibility !!!\n'${SC}
    mapfile blkDevList < <( lsblk --scsi --paths --noheadings --output NAME,TYPE,SIZE,MODEL )
    for item in $(seq 0 $(( ${#blkDevList[@]} - 1))) 
    do
        echo $(( $item + 1))' --> '${blkDevList[$item]}
    done
    echo -e '\n0 - quit the script\n'
}


function select_blk_dev() { # allows selecting a block device for the alignment test
    select_blk_dev_menu 
    blkDevNum=$(( ${#blkDevList[@]} + 1 ))  # $blkDevList array is enumerated in select_blk_dev_menu() function
    while [ $blkDevNum -lt 1 ] || [ $blkDevNum -gt ${#blkDevList[@]} ]
    do
        read -p 'Enter a number corresponding to the menu item: ' blkDevNum
        if  ! [[ $blkDevNum =~ ^[0-9]+$ ]]
        then
            blkDevNum=$(( ${#blkDevList[@]} + 1 ))
            select_blk_dev_menu
        else 
            if [ $blkDevNum -eq 0 ]; then quit_now; fi
        fi
    done
    (( blkDevNum-- ))    # decreases $blkDevNum by 1, as menu numbers were greater by 1 than $blkDevList array indices
    blkDevPath=$(echo ${blkDevList[$blkDevNum]} | gawk --field-separator ' ' '{print $1}')
    draw_line
    echo -e '\nYou have selected '${BLUE}${blkDevList[$blkDevNum]}
}


function zero_blk_dev() {   # overwrite first 1MiB of selected block device with zeros
    echo -e ${LRED}'\nYou are going to destroy the current content of disk '${BLUE}$blkDevPath${LRED}' !!!'${SC}
    yes_or_not
    echo -e -n '\nOverwritting beginning area of '$blkDevPath' ...'
    dd if=/dev/zero of=$blkDevPath bs=4096 count=25 >& /dev/null
    if ! [ $? -eq 0 ] 
    then
        echo -e ${LRED}'Something went wrong.'${SC}
        quit_now
    else
        echo -e ${LGREEN}' Done'${SC}  
    fi
    echo -e -n '\nCreating '${BLUE}'msdos'${SC}' disk label (MBR) on disk '$blkDevPath' ...'
    parted --script $blkDevPath mklabel msdos # creates disk label (partition table type): msdos (MBR) 
    echo -e ${LGREEN}' Done'${SC} 
}


function align_partition_and_test() {
    # echo $scriptConfig | jq '.parted[0]'
    for dataSetNo in $(seq 0 $(( $(echo $scriptConfig | jq '.parted' | jq 'length') -1 )))
    do
        # --- begin --- assign settings to the variables
        partedAlignmentType=$(echo $scriptConfig | jq '.parted['$dataSetNo'].align' | sed 's/\"//g')
        partedUnit=$(echo $scriptConfig | jq '.parted['$dataSetNo'].unit' | sed 's/\"//g')
        partedStartOffset=$(echo $scriptConfig | jq '.parted['$dataSetNo'].start_offset')
        partedEndOffset=$(echo $scriptConfig | jq '.parted['$dataSetNo'].end_offset')
        # --- end --- assign settings to the variables

        # --- begin --- exposes the partition/alignment settings 
        draw_line 
        echo -e ${BLUE}'\nTest no. '$(( $dataSetNo + 1 ))
        echo -e ${SC}'\nAlignment Type: '${ORANGE}$partedAlignmentType
        echo -e ${SC}'Unit: '${ORANGE}$partedUnit
        echo -e ${SC}'Start Offset: '${ORANGE}$partedStartOffset
        echo -e ${SC}'End Offset: '${ORANGE}$partedEndOffset${SC}
        # --- end --- exposes the partition/alignment settings 
        
        # creates a primary partition due to the settings read from $CONFIGFILE
        parted --script --align $partedAlignmentType $blkDevPath unit $partedUnit mkpart primary $partedStartOffset $partedEndOffset
        
        # --- begin --- performs a writing test of 1GiB by dd to the newly created partition, and prints the results
        echo -e '\nWriting test result by '${BLUE}'dd'${SC}': '
        dd if=/dev/zero of=$(echo $blkDevPath'1') bs=1M count=1000
        # --- end --- performs a writing test of 1GiB by dd to the newly created partition, and prints the results

        # --- begin --- prints partition info with sector as a parted's unit, and then, removes this partition 
        echo -e '\nDisk info by '${BLUE}'parted'${SC}': '
        parted $blkDevPath unit s print
        parted --script $blkDevPath rm 1
        # --- end --- prints partition info with sector as a parted's unit, and then, removes this partition 
    done 
}

check_if_root
preconfig
select_blk_dev
zero_blk_dev
align_partition_and_test 
exit
                                       
