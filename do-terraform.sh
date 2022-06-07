#!/bin/bash

# Program settings
### COLOR
RED='\033[0;91m'
RED_B='\033[0;101m'
GREEN='\033[0;32m'
EOC='\033[0m'


# Check Input Arguments
if [[ -z $1 || -z $2 || -z $3 ]]; then
  echo -e "${RED}Use: $0 <PATH DIR> <TERRAFORM WORKSPACE> <TERRAFORM COMMAND>${EOC}"
  echo -e "${GREEN}Example: $0 live/stage/vpc dev plan${EOC}"
  exit -1
fi


# Check directory path
cd $1
if [[ $? -ne 0 ]]; then
  exit -1
fi
DIR=$1


# Check Workspace restriction
T_WORKSPACES=('dev' 'prod')

if [[ " ${T_WORKSPACES[*]} " =~ " $2 " ]]; then
  WORKSPACE=$2
else
  echo -e "${RED}Workspace $2 is not available${EOC}"
  echo -e "${GREEN}Available Workspaces are: ${T_WORKSPACES[@]}${EOC}"
  exit -1
fi

# Check terraform command
T_COMMANDS=('plan' 'apply' 'destroy')

if [[ " ${T_COMMANDS[*]} " =~ " $3 " ]]; then
  COMMAND="terraform $2"
else
  echo -e "${RED}Command $3 is not available${EOC}"
  echo -e "${GREEN}Available Commands are: ${T_COMMANDS[@]}${EOC}"
  exit -1
fi

# Show pwd message
echo -e "Current Directory: ${RED}`pwd`${EOC}"

# Change Terraform Workspace
# If there is no workspace Then Create it
terraform workspace select $2
if [[ $? -ne 0 ]]; then
  echo -e "There is no workspace $2"
  terraform workspace new $2
fi
echo -e "Current Workspace: ${RED_B}`terraform workspace show`${EOC}"


T_FILES=`find . -type f -name "*.tf"`
if [[ ${#T_FILES[@]} -le 0 ]]; then
  echo "There is no terraform file"
  exit -1
fi

echo -e "Command will execute: $COMMAND"
echo -e "Directory: $DIR"

