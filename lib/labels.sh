#!/bin/bash

##################################################
# Creates a single label on a repository
#
# @param $1: Repository name
# @param $2: Label name
# @param $3: Label color
##################################################
Github__create_single_label(){
    # Try to create via POST
    local post_output=$(curl \
        -s \
        -H "Authorization: token $GITHUB_TOKEN" \
        -X POST "https://api.github.com/repos/$1/labels" \
        -d "{\"name\":\"$2\", \"color\":\"$3\"}")

    # Checking if POST worked
    local post_errors=$(echo "$post_output" | grep "\"errors\":")
    if [[ -z "$post_errors" ]]; then
        echo "1"
        return
    fi

    # Update via PATCH
    local patch_output=$(curl \
        -s \
        -H "Authorization: token $GITHUB_TOKEN" \
        -X PATCH "https://api.github.com/repos/$1/labels/$2" \
        -d "{\"name\":\"$2\", \"color\":\"$3\"}")

    # Checking if PATCH worked
    local patch_errors=$(echo "$patch_output" | grep "\"errors\":")
    if [[ -z "$patch_errors" ]]; then
        echo "1"
    else
        echo "0"
    fi
}
