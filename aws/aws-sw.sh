#!/bin/bash
#
#  Annotation

PATH_TO_AWS_CONFIG=~/.aws/config

function MESSAGE (){
  echo -e "\n-----------------------------------------------"
  echo "${1}"
  echo -e "-----------------------------------------------\n"
}

function ERROR () {
  MESSAGE "[ ERROR ] ${1}"
  exit 0
}

function Read-Current-Profile () {
  if [ -z $AWS_PROFILE ]   
  then     
    SH_CURRENT_AWS_PROFILE=`aws configure list | grep 'profile' | awk '{print $2}'`   
  else     
    SH_CURRENT_AWS_PROFILE=$AWS_PROFILE   
  fi
}

function Helping () {
  #echo -e "\nThis script allows you to switch to any AWS Profile placed in the ~/.aws/config file"
  echo -e "Usage: ./aws-pr-sw.sh [OPTIONS]"
  echo -e "\nThis script allows you to switch to any AWS Profile placed in the ~/.aws/config file"
  echo -e "Without any options script shows the list of all profiles and lets you set profile for default\n"
  echo -e "OPTIONS:"
  echo -e "  -h    Show the script usage"
  echo -e "  -c    Show the current used profile only"
  echo -e "  -l    Show the list of existed profiles"
  echo -e "  -f    Is used for filtering profiles which are matched, can be used in conjuction with -l option or without"
  echo -e ""
}

function List-Profiles () {
  Read-Current-Profile
  
  if [ -s $PATH_TO_AWS_CONFIG ]
  then
    if [ -n ${1} ]
    then	    
      PROFILE_LIST=( $(cat $PATH_TO_AWS_CONFIG | grep [\[].*$1.*[\]] | sed 's/profile\|\s\|\[\|\]//g') )
    else
      PROFILE_LIST=( $(cat $PATH_TO_AWS_CONFIG | grep [\[].*[\]] | sed 's/profile\|\s\|\[\|\]//g') )
    fi	    
  else
    ERROR "There are not aws cli config file"
  fi

  INDEX=0
  echo ""
  for PROFILE in ${PROFILE_LIST[@]}; do
    if [ $PROFILE == $SH_CURRENT_AWS_PROFILE ]
    then	  
      SC="*"
    else
      SC="" 
    fi
    printf "%1s%2d - %s\n" "$SC" $INDEX "$PROFILE"
    (( INDEX++ )) 
  done	
  echo ""
}


function Set-Profile () {
  ATTEMPT_NUMBER=3
  I=0
  FLAG="false"
  NUMBER=""
  while [ $I -lt $ATTEMPT_NUMBER ]
  do
   echo -n "Enter a profile index number [from 0 to $(($INDEX - 1))] ===> "
    read NUMBER
    if [ -z $(echo $NUMBER | sed -e 's/[0-9]//g') ]
    then
      if [ $NUMBER -ge 0 -a $NUMBER -le $(($INDEX - 1)) ]; then
        FLAG="true"
        break
      else
        echo "  Please specify correct number in range 0 - $(($INDEX - 1))"
      fi
    else
      echo "  Please specify digits only !!!"
    fi
    ((I++))
  done

  if [ $FLAG == "true" ]; then
    export AWS_PROFILE="${PROFILE_LIST[$NUMBER]}"
  else
    echo -e "Oops, you exceeded you amount of attempts!!! Exited..."
    exit 0
  fi
}

function Validate-Profile () {
  if [ -n $AWS_PROFILE ]
  then
    echo -e "\n  Now current AWS profile is \"$AWS_PROFILE\"\n"
  else
    MESSAGE "[ WARN ] AWS Profile is empty\n"
  fi
}

# main block
FILTER=""
LS="false"
CURRENT="false"
HELP="false" 
while getopts "hlcf:" opt; do
  case $opt in
    l) 
      LS="true"
    ;;
    c) 
      CURRENT="true"
    ;;
    f) 
      FILTER=$OPTARG
    ;;  
    h)
      HELP="true"
    ;;
  esac
done


# echo $LS
# echo $CURRENT
# echo $FILTER
# echo $HELP


if [ $HELP == "true" ]
then
  Helping
fi

if [ $LS == "true" ]
then
  List-Profiles $FILTER
fi

if [ $CURRENT == "true" ]
then
  Read-Current-Profile
  echo -e "\n  Current profile: $SH_CURRENT_AWS_PROFILE \n"
fi

if [ $HELP == "false" -a $LS == "false" -a $CURRENT == "false" ]
then
  List-Profiles $FILTER
  Set-Profile
  Validate-Profile
fi

##export AWS_PROFILE="personal-gloover"