#!/bin/bash

# Program settings
### COLOR
RED='\033[0;91m'
RED_B='\033[0;101m'
GREEN='\033[0;32m'
EOC='\033[0m'

# Check Input Arguments

# TERRAFORM COMMAND
COMMAND="terraform $2"

# WORKING DIRECTORY
DIR=$1

# VAR FILES



# Change Directory
cd $DIR
if [[ $? -ne 0 ]]; then
  exit -1
fi

T_FILES=`find . -type f -name "*.tf"`
if [[ ${#T_FILES[@]} -le 0 ]]; then
  echo "There is no terraform file"
  exit -1
fi

echo -e "Current Workspace: ${RED_B}`terraform workspace show`${EOC}"
echo -e "Command will execute: $COMMAND"
echo -e "Directory: $DIR"

