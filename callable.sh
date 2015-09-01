#!/bin/bash
Ash__import "ghtools"

Ghtools_label_config_directory="$Ash__call_directory/extras/label_configs"

##################################################
# Just an alias for help
##################################################
Ghtools__callable_main(){
    Ghtools__callable_help
}

##################################################
# Displays out the HELP.txt file
##################################################
Ghtools__callable_help(){
    more "$Ash__active_module_directory/HELP.txt"
}

##################################################
# Loads up a github repo with the labels
# as defined in the passed in label config
#
# @param $1: The label config file
##################################################
Ghtools__callable_labels(){
    # Checking if we've got a valid config file
    local label_config_file="$Ghtools_label_config_directory/$1"
    if [[ ! -f "$label_config_file" ]]; then
        Logger__error "Requires a valid label config file to be passed in"
        Logger__error "Here are the current label config files available:"
        ls $Ghtools_label_config_directory
        exit
    fi

    # Grabbing repo + validating input
    Logger__prompt "Input the the repository to add labels (ex, carrot/ash-ghtools): "; read repo
    if [[ ! "$repo" =~ .+/.+ ]]; then
        Logger__error "Invalid repository format (ex, carrot/ash-ghtools)"
        exit
    fi

    # Adding all labels
    while read line; do
        local label=$(echo $line | awk -F':' '{print $1}')
        local color=$(echo $line | awk -F':' '{print $2}')

        success=$(Ghtools_create_single_label "$repo" "$label" "$color")
        if [[ "$success" -eq "1" ]]; then
            Logger__success "Added label: $label"
        else
            Logger__warning "Failed to add label: $label"
        fi
    done < $label_config_file
}
