#!/bin/bash
Ash__import "github"

Github_label_config_directory="$Ash__active_module_directory/extras/label_configs"

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
    more "$Ash__active_module_directory/HELP.txt"
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

    # Checking if we've got a valid config file
    local label_config_file="$Github_label_config_directory/$1"
    if [[ ! -f "$label_config_file" ]]; then
        Logger__error "Requires a valid label config file to be passed in"
        Logger__error "Here are the current label config files available:"
        ls $Github_label_config_directory
        exit
    fi

    # Grabbing repo + validating input
    Logger__prompt "Input the the repository to add labels (ex, carrot/ash-github): "; read repo
    if [[ ! "$repo" =~ .+/.+ ]]; then
        Logger__error "Invalid repository format (ex, carrot/ash-github)"
        exit
    fi

    # Adding all labels
    while read line; do
        local label=$(echo $line | awk -F':' '{print $1}')
        local color=$(echo $line | awk -F':' '{print $2}')

        response=$(Github__create_single_label "$repo" "$label" "$color")

        if [[ "$response" = "added" ]]; then
            Logger__success "Added label: $label"
        elif [[ "$response" = "updated" ]]; then
            Logger__success "Updated label: $label"
        else
            Logger__warning "Failed to add label: $label"
        fi
    done < $label_config_file
}
