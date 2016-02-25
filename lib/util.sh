#!/bin/bash

##################################################
# Validates if the GITHUB_TOKEN is set in the
# .ashrc file.  Prompts the user to set one if it
# hasn't been set yet.
#
# @returns: 0 if there is a Github token set at
#               the end of this function call
#           1 if there is *not* a Github token set
#               at the end of this function call
##################################################
Github_validate_token(){
    # Checking if variable exists
    if [[ -z "$GITHUB_TOKEN" ]]; then
        local response
        Logger__alert "GITHUB_TOKEN is not set in the .ashrc file"
        Logger__prompt "Would you like to set one now? (y/n): "; read response

        # If user wants to input their token
        if [[ "$response" = "y" || "$response" = "Y" ]]; then
            local github_token
            Logger__prompt "Enter Github Token (https://github.com/settings/tokens): "; read github_token

            local export_line="export GITHUB_TOKEN=\"$github_token\""
            echo "$export_line" >> $Ash__RC_FILE # Store it to .ashrc
            export GITHUB_TOKEN="$github_token" # Exporting for current use
            return 0
        else
            return 1
        fi
    else
        return 0
    fi
}
