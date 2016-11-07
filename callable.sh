#!/bin/bash

##################################################
# Just an alias for help
##################################################
Github__callable_main(){
    Github__callable_help
}

##################################################
# Displays out the HELP.txt file
##################################################
Github__callable_help(){
    more "$Ash__ACTIVE_MODULE_DIRECTORY/HELP.txt"
}

##################################################
# Loads up a github repo with the labels
# as defined in the passed in label config
#
# @param $1: The label config file
##################################################
Github__callable_labels(){
    # Checking if variable exists
    Github_validate_token
    if [[ $? -ne 0 ]]; then
        Logger__error "GITHUB_TOKEN must be set in the .ashrc file before calling labels"
        return
    fi

    if [[ "$1" == "list" ]]; then
        ls "$Github_label_config_directory"
        return
    elif [[ ! $1 =~ (.*)\/(.*) ]]; then
        repo=""
        label=$1
    else
        repo=$1
        label=$2
    fi


    # Grabbing repo + validating input
    if [[ "$repo" == "" ]]; then
        if [[ -d .git ]] && [[ $(git config --local --get remote.origin.url) =~ git@github\.com:(.*)\/(.*)\.git ]]; then
            repo="${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
        else
            Logger__prompt "Input the the repository to add labels (ex, carrot/ash-github): "; read repo
            if [[ ! "$repo" =~ .+/.+ ]]; then
                Logger__error "Invalid repository format (ex, carrot/ash-github)"
                return
            fi
        fi
    fi

    # Handling the config file
    Github__labels_handle_config_file "$repo" "$label" 0
}
