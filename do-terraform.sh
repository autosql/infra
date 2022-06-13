#!/bin/bash

######################################################################################
# Program settings
######################################################################################
# Set Color Constant
# -----------------------------------
ERROR='\033[1;91m' # Red
RESULT='\033[0;101m' # Background Red
INFO='\033[4;36m' # Cyan
EOC='\033[0m' # End of Color

# Set Flags
# -----------------------------------
F_GLOBAL_TFVARS=0
F_AUTO_APPROVE=0

# Set Variables
# -----------------------------------
GLOBAL_TFVARS=""
ORIGINAL_DIR=`realpath ./`
LOG_FILE="$ORIGINAL_DIR/tf.log"
INFRA_LOG_FILE="$ORIGINAL_DIR/tf-infra.log"
ORIGINAL_COMMAND="$0 $@"

# Create Log Files, if not exists
# -----------------------------------
if [[ ! -f "$LOG_FILE" ]]; then
  touch "$LOG_FILE"
fi
if [[ ! -f "$INFRA_LOG_FILE" ]]; then
  touch "$INFRA_LOG_FILE"
fi

######################################################################################
# Option settings
######################################################################################
while getopts "g:y" opt;
do
  case $opt in
    g)
      F_GLOBAL_TFVARS=1
      ls $OPTARG 1> /dev/null
      if [[ $? -ne 0 ]]; then exit -1; fi
      GLOBAL_TFVARS=`realpath $OPTARG`
      ;;
    y)
      F_AUTO_APPROVE=1
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
  esac
done

shift $((OPTIND-1))


######################################################################################
# Exit Conditions
######################################################################################
# Check Input Arguments
# -----------------------------------
if [[ -z $1 || -z $2 || -z $3 ]]; then
  echo -e "${ERROR}Use: $0 <OPTIONS> <PATH DIR> <TERRAFORM WORKSPACE> <TERRAFORM COMMAND>${EOC}"
  echo -e "${INFO}Example: $0 -g global/g.tfvars -v live/stage/vpc dev plan${EOC}"
  echo -e "${INFO}Options: ${EOC}"
  echo -e "\t\t${INFO}-g <.tfvars PATH>${EOC}"
  echo -e "\t\t\t${INFO}Specified tfvars files path for global used ${EOC}"
  echo -e ""
  echo -e "\t\t${INFO}-v${EOC}"
  echo -e "\t\t\t${INFO}Auto Approval options${EOC}"
  exit -1
fi


# Check Directory path
# -----------------------------------
cd $1
if [[ $? -ne 0 ]]; then
  exit -1
fi
DIR=$1


# Check Workspace restriction
# -----------------------------------
T_WORKSPACES=('dev' 'prod')

if [[ " ${T_WORKSPACES[*]} " =~ " $2 " ]]; then
  WORKSPACE=$2
else
  echo -e "${ERROR}Workspace $WORKSPACE is not available${EOC}"
  echo -e "${INFO}Available Workspaces are: ${T_WORKSPACES[@]} ${EOC}"
  exit -1
fi

# Check Terraform command
# -----------------------------------
T_COMMANDS=('plan' 'apply' 'destroy' 'console' 'output')

if [[ " ${T_COMMANDS[*]} " =~ " $3 " ]]; then
  COMMAND="terraform $3"
  T_COMMAND=$3
else
  echo -e "${ERROR}Command $T_COMMAND is not available${EOC}"
  echo -e "${INFO}Available Commands are: ${T_COMMANDS[@]} ${EOC}"
  exit -1
fi

# Check Terraform file exists
# -----------------------------------
T_FILES=`find . -type f -name "*.tf"`
if [[ ${#T_FILES[@]} -le 0 ]]; then
  echo "${ERROR}There is no terraform file${EOC}"
  exit -1
fi

# Print pwd message
# -----------------------------------
echo -e "${INFO}Current Directory: ${RESULT}`pwd`${EOC}"

######################################################################################
# Create Command to be execute 
######################################################################################
# Create Workspace If doesn't exist 
# -----------------------------------
terraform workspace select $WORKSPACE
if [[ $? -ne 0 ]]; then
  echo -e "${INFO}There is no workspace $WORKSPACE, So Create workspace $WORKSPACE ${EOC}"
  EXISTING_WORKSPACE=`terraform workspace show`
  terraform workspace new $WORKSPACE
  terraform workspace select $WORKSPACE
fi
echo -e "${INFO}Current Workspace: ${RESULT}`terraform workspace show`${EOC}"

# Create -var-file Options with files inside working directory
# -----------------------------------
T_VARS=`find . -type f -name "*.tfvars"`
if [[ ${#T_VARS[@]} -gt 0 ]]; then
  for vars in "${T_VARS[@]}"; do
    if [[ -n $vars ]]; then
      COMMAND="$COMMAND -var-file=$vars"
    fi
  done
fi

if [[ $F_GLOBAL_TFVARS -eq 1 ]]; then
  COMMAND="$COMMAND -var-file=$GLOBAL_TFVARS"
fi

if [[ $F_AUTO_APPROVE -eq 1 && "$T_COMMAND" == "apply" || "$T_COMMAND" == "destroy" ]]; then
  COMMAND="$COMMAND -auto-approve"
fi

if [[ "$T_COMMAND" == "console" ]]; then
  COMMAND="$COMMAND -state=./terraform.tfstate.d/$WORKSPACE/terraform.tfstate"
fi

######################################################################################
# Show Final command
######################################################################################
echo ""
echo -e "${INFO}The command will be execute: ${RESULT}$COMMAND ${EOC}"

######################################################################################
# Wait User answer
######################################################################################
if [[ $F_AUTO_APPROVE -eq 1 ]]; then
  yn=y
else
  read -p "Continue (y or n): " yn
fi

case $yn in
  [yY] )
    eval $COMMAND

    # Logging 
    # -----------------------------------
    if [[ $? -eq 0 ]]; then
      UTC=`TZ='Asia/Seoul' date +%Y-%m-%dT%H:%M:%S%Z`
      COMMAND_LOG="$UTC [COMMAND]\$ $ORIGINAL_COMMAND"
      EXECUTED_LOG="$UTC [EXECUTED]\$ $COMMAND"

      echo $COMMAND_LOG >> $LOG_FILE
      echo $EXECUTED_LOG >> $LOG_FILE
      echo "" >> $LOG_FILE

      if [[ "$T_COMMAND" == "apply" || "$T_COMMAND" == "destroy" ]]; then
        INFRA_LOG="$UTC [`echo $T_COMMAND | tr [:lower:] [:upper:]`]\$ $COMMAND"

        echo $COMMAND_LOG >> $INFRA_LOG_FILE
        echo $INFRA_LOG >> $INFRA_LOG_FILE
      fi

    fi
    ;;
  [nN] )
    # Clean Up
    # -----------------------------------
    if [[ -n $EXISTING_WORKSPACE ]]; then
      echo -e "${INFO}Delete created workspace: $WORKSPACE ${EOC}"
      terraform workspace select $EXISTING_WORKSPACE
      terraform workspace delete $WORKSPACE
    fi
    exit 0
    ;;
  * )
    echo -e "${INFO}Invalid Keyword${EOC}"
    ;;
esac

