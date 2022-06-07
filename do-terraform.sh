#!/bin/bash

# Program settings
### COLOR
ERROR='\033[0;91m' # Red
ERROR_B='\033[0;101m' # Background Red
MSG='\033[0;32m' # Green
INFO='\033[0;36m' # Cyan
EOC='\033[0m' # End of Color


# Check Input Arguments
if [[ -z $1 || -z $2 || -z $3 ]]; then
  echo -e "${ERROR}Use: $0 <PATH DIR> <TERRAFORM WORKSPACE> <TERRAFORM COMMAND>${EOC}"
  echo -e "${MSG}Example: $0 live/stage/vpc dev plan${EOC}"
  exit -1
fi


# Check Directory path
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
  echo -e "${ERROR}Workspace $2 is not available${EOC}"
  echo -e "${MSG}Available Workspaces are: ${T_WORKSPACES[@]}${EOC}"
  exit -1
fi

# Check Terraform command
T_COMMANDS=('plan' 'apply' 'destroy')

if [[ " ${T_COMMANDS[*]} " =~ " $3 " ]]; then
  COMMAND="terraform $3"
else
  echo -e "${ERROR}Command $3 is not available${EOC}"
  echo -e "${MSG}Available Commands are: ${T_COMMANDS[@]}${EOC}"
  exit -1
fi

# Check Terraform file exists
T_FILES=`find . -type f -name "*.tf"`
if [[ ${#T_FILES[@]} -le 0 ]]; then
  echo "${ERROR}There is no terraform file${EOC}"
  exit -1
fi

echo -e "\n"

# Show pwd message
echo -e "${MSG}Current Directory: ${INFO}`pwd`${EOC}"

# Change Terraform Workspace
# If there is no workspace Then Create it
terraform workspace select $2
if [[ $? -ne 0 ]]; then
  echo -e "There is no workspace $2"
  terraform workspace new $2
fi
echo -e "${MSG}Current Workspace: ${ERROR_B}`terraform workspace show`${EOC}"

# Make Command with var files
T_VARS=`find . -type f -name "*.tfvars"`
if [[ ${#T_VARS[@]} -gt 0 ]]; then
  for vars in "${T_VARS[@]}"; do
    COMMAND="$COMMAND -var-file=$vars"
  done
fi

echo -e "${MSG}Command will execute: ${INFO}$COMMAND${EOC}"

