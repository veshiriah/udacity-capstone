#!/bin/bash

function create_update_stack() {
    STACK_NAME=$1
    CHANGE_SET_NAME=$2
    TEMPLATE_FILE_NAME=$3
    PARAMETERS=$4

    echo "** Checking if stack exists **"
    if aws cloudformation describe-stacks --stack-name $1 > /dev/null 2>&1; then
        CHANGE_SET_TYPE="UPDATE"
        CHANGE_SET_TYPE_LOWER="update"
    else
        CHANGE_SET_TYPE="CREATE"
        CHANGE_SET_TYPE_LOWER="create"
    fi
    echo "CHANGE_SET_TYPE is $CHANGE_SET_TYPE"

    echo "** Create change set for $1 product stack **"
    aws cloudformation create-change-set --stack-name "$1" --template-url file://aws/$3 \
                                        --change-set-name "$2" --change-set-type $CHANGE_SET_TYPE \
                                        --parameters file://aws/$4
                                        --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND

    aws cloudformation wait change-set-create-complete --stack-name "$1" --change-set-name "$2"

    echo "** Execute change set for $1 stack **"
    aws cloudformation execute-change-set --stack-name "$1" --change-set-name "$2"
    aws cloudformation wait stack-${CHANGE_SET_TYPE_LOWER}-complete --stack-name "$1"

    echo "** Delete change set for $1 stack **"
    aws cloudformation delete-change-set --stack-name "$1" --change-set-name "$2"
}
