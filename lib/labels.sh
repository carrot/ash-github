#!/bin/bash

# Label Configs location
Github_label_config_directory="$Ash__ACTIVE_MODULE_DIRECTORY/extras/label_configs"

##################################################
# Loads in a config file and handles it
#
# @param $1: The repo name
# @param $2: The labels config name
# @param $3: 1 if this is an import
#            0 if this is the base file
##################################################
Github__labels_handle_config_file(){
    # Checking if we've got a valid config file
    local label_config_file="$Github_label_config_directory/$2"
    if [[ ! -f "$label_config_file" ]]; then
        # Import
        if [[ $3 -eq 1 ]]; then
            Logger__error "Failed to import: $2"
        # Base File
        else
            Logger__error "Requires a valid label config file to be passed in"
            Logger__error "Here are the current available label config files:"
            ls $Github_label_config_directory
            Logger__prompt "Input a label config from above (ex, carrots): "; read label
            label_config_file="$Github_label_config_directory/$label"
            if [[ ! -f "$label_config_file" ]]; then
                # Retry Import
                if [[ $3 -eq 1 ]]; then
                    Logger__error "Failed to import: $label"
                else
                    Logger__error "Label config does not exist."
                    exit
                fi
            fi
        fi
    fi

    # Adding all labels
    while read line; do
        # Removing comments
        local line=$(echo "$line" | sed 's/\ *#.*//g')
        if [[ ${#line} -eq 0 ]]; then
            continue
        fi

        # Handling action
        Github__handle_action "$1" "$line"
    done < $label_config_file
}

##################################################
# Handles a single line within a config file
#
# @param $1: The repo name
# @param $2: The comment parsed line in a
#            label_config file.
##################################################
Github__handle_action(){
    # Checking if action
    if [[ $2 == -* ]]; then
        local action=$(echo $2 | awk -F':' '{print $1}')

        # Action is delete
        if [[ "$action" == "-delete" ]]; then
            local label=$(echo $2 | awk -F':' '{print $2}')

            if [[ "$label" == "all" ]]; then
                Github__delete_labels "$1"
            else
                local response=$(Github__delete_label "$1" "$label")
                if [[ "$response" = "deleted" ]]; then
                    Logger__success "Deleted Label: $label"
                else
                    Logger__warning "Failed to delete label: $label"
                fi
            fi

        # Action is import
        elif [[ "$action" == "-import" ]]; then
            local import_file=$(echo $2 | awk -F':' '{print $2}')
            Github__labels_handle_config_file "$1" "$import_file" 1
        fi

    # Default add line
    else
        local label=$(echo $2 | awk -F':' '{print $1}')
        local color=$(echo $2 | awk -F':' '{print $2}')

        local response=$(Github__create_single_label "$1" "$label" "$color")

        if [[ "$response" = "added" ]]; then
            Logger__success "Added label: $label"
        elif [[ "$response" = "updated" ]]; then
            Logger__success "Updated label: $label"
        else
            Logger__warning "Failed to add label: $label"
        fi
    fi
}

##################################################
# Deletes a single label from a repository
#
# @param $1: The repo name
# @param $2: The label name
#
# @returns: 'failure' if we failed to delete the label
#           'deleted' if we successfully deleted the label
##################################################
Github__delete_label(){
    local repo="$1"
    local label="$2"
    label=$(echo "$label" | sed 's/\ /%20/g')

    # Try to delete via DELETE
    local delete_response=$(curl \
        -s -o /dev/null -w "%{http_code}" \
        -H "Authorization: token $GITHUB_TOKEN" \
        -X DELETE "https://api.github.com/repos/$repo/labels/$label")

    # Checking if DELETE worked
    if [[ $delete_response =~ 2.. ]]; then
        echo "deleted"
        return
    fi

    echo "failure"
}

##################################################
# Deletes all labels from a repository
#
# @param $1: The repo name
#
# @returns: 'failure' if we failed to delete the label
#           'deleted' if we successfully deleted the label
##################################################
Github__delete_labels(){
    local repo="$1"
    # fetch all labels
    local labels=$(curl \
        -s \
        -H "Authorization: token $GITHUB_TOKEN" \
        -X GET "https://api.github.com/repos/$repo/labels")

    echo "$labels" | while IFS='' read -r line || [[ -n "$line" ]]; do
        if [[ "$line" =~ (\"name\":)(\s?)(.*)\" ]]; then 
            if [[ "${BASH_REMATCH[3]}" =~ \"(.*) ]]; then
                label="${BASH_REMATCH[1]}"
                local delete_response=$(curl \
                    -s -o /dev/null -w "%{http_code}" \
                    -H "Authorization: token $GITHUB_TOKEN" \
                    -X DELETE "https://api.github.com/repos/$repo/labels/$label")
                if [[ $delete_response =~ 2.. ]]; then
                    Logger__success "Deleted Label: $label"
                else
                    Logger__warning "Failed to delete label: $label"
                fi
            fi
        fi
    done
}

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
