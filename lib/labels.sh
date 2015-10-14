#!/bin/bash

##################################################
# Creates a single label on a repository
#
# @param $1: Repository name
# @param $2: Label name
# @param $3: Label color
#
# @returns: 'failure' if we failed to add / update the label
#           'added' if we successfully added the label
#           'updated' if we successfully updated the label
##################################################
Github__create_single_label(){
    # Try to create via POST
    local post_response=$(curl \
        -s -o /dev/null -w "%{http_code}" \
        -H "Authorization: token $GITHUB_TOKEN" \
        -X POST "https://api.github.com/repos/$1/labels" \
        -d "{\"name\":\"$2\", \"color\":\"$3\"}")

    # Checking if POST worked
    if [[ $post_response =~ 2.. ]]; then
        echo "added"
        return
    fi

    # Update via PATCH
    local patch_response=$(curl \
        -s -o /dev/null -w "%{http_code}" \
        -H "Authorization: token $GITHUB_TOKEN" \
        -X PATCH "https://api.github.com/repos/$1/labels/$2" \
        -d "{\"name\":\"$2\", \"color\":\"$3\"}")

    # Checking if PATCH worked
    if [[ $patch_response =~ 2.. ]]; then
        echo "updated"
    else
        echo "failure"
    fi
}
