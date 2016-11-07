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

Github__callable_repo(){
    if [[ "$1" == "" ]];then
        Github__callable_help
    else
        for param in "$@"; do
            if [[ "$param" == "new" ]]; then
                Github__repo_new ${@:2}
            elif [[ "$param" == "delete" ]]; then
                Github__repo_delete ${@:2}
            else
                Logger__error "Unknown operation: \"$param\""
                Github__callable_help
            fi
        done
    fi
}

Github__repo_new(){
    Github_validate_token

    # flags
    local name=''                                 # default: ''    *Required
    local description=''                          # default: ''
    local homepage=''                             # default: ''
    local private=false                           # default: false
    local hasIssues=true                          # default: true
    local hasWiki=true                            # default: true
    local hasDownloads=true                       # default: true
    local teams=''                                # default: ''     **integer
    local autoInit=false                          # default: false
    local gitignore=''                            # default: ''
    local license=''                              # default: ''
    local verbose=false                           # default: false
    local dryRun=false                            # default: false
    local curlOpts=''                             # curlOpts
    local url="https://api.github.com/user/repos" # api url

    if [[ ! "$#" -ne 1 ]]; then # only name
            name="$1"
    elif [[ "$1" =~ ^((-{1,2})([Hh]$|[Hh][Ee][Ll][Pp])|)$ ]]; then
        Github__callable_help
    else
        while [[ $# -gt 0 ]]; do
            opt="$1"
            shift;
            current_arg="$1"
            case "$opt" in
                "-n"|"--name"              ) name="$1"; shift;;
                "-d"|"--description"       ) description="$1"; shift;;
                "-h"|"--homepage"          ) homepage="$1"; shift;;
                "-p"|"--private"           ) private=true; shift;;
                "-i"|"--disable-issues"    ) hasIssues=false; shift;;
                "-w"|"--disable-wiki"      ) hasWiki=false; shift;;
                "-D"|"--disable-downloads" ) hasDownloads=false; shift;;
                "-t"|"--teams"             ) teams="$1"; shift;;
                "-a"|"--auto-init"         ) autoInit=true; shift;;
                "-g"|"--gitignore"         ) gitignore="$1"; shift;;
                "-l"|"--license"           ) license="$1"; shift;;
                "-v"|"--verbose"           ) verbose=true; shift;;
                "-r"|"--dry-run"           ) dryRun=true; shift;;
                *                          ) Logger__error "Invalid option: \""$opt"\""
            esac
        done
    fi

    if [[ "$name" == "" ]]; then
        Logger__error "You must pass a name"
        return
    fi

    # data
    local data="{
\"name\": \"$name\",
\"description\": \"$description\",
\"homepage\": \"$homepage\",
\"private\": $private,
\"has_issues\": $hasIssues,
\"has_wiki\": $hasWiki,
\"has_downloads\": $hasDownloads,
\"team_id\": \"$teams\",
\"auto_init\": $autoInit,
\"gitignore_template\": \"$gitignore\",
\"license_template\": \"$license\"
}"

    if [[ "$verbose" == true ]]; then
        curlOpts+='--verbose'
    else
        curlOpts+='-s'
    fi

    if [[ "$org" != "" ]]; then # orgs
        url="https://api.github.com/orgs/$org/repos"
    fi

    if [[ "$dryRun" == true ]]; then # dry run thru proxy
        nc -l localhost 8000 & \
        curl "$curlOpts" \
        --proxy localhost:8000 \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Content-Type: application/json" \
        -X POST "$url" \
        -d "$data"
        echo "body: $data"
    else # real request
        local res=$(curl -s \
            "$curlOpts" \
            -H "Authorization: token $GITHUB_TOKEN" \
            -H "Content-Type: application/json" \
            -X POST "$url" \
            -d "$data")

        if [[ ! "$res" =~ 2.. ]]; then
            echo "Failed to create your repository."
            echo "Status: $res"
        else
            echo "Successfully created your repository."
        fi
    fi
}

Github__repo_delete(){
    local url="https://api.github.com/repos/$@"
    local repo=''

    if [[ ! "$@" =~ .*\/.* ]]; then
        echo "Pass your repository as owner/repo. (ie, ash-shell/foo)"
        return
    fi

    Github_validate_token
    Logger__prompt "Please type in the name of the repository to confirm: "; read response
    if [[ "$@" =~ (.*)\/(.*) ]]; then
        if [[ "$response" = "${BASH_REMATCH[2]}" ]]; then
            local res=$(curl \
                -s \
                -H "Authorization: token $GITHUB_TOKEN" \
                -X DELETE "$url")

            if [[ $res != "" ]]; then
                echo "Failed to delete repository."
                echo "Status: $res"
            else
                echo "Successfully deleted repository."
            fi
        else
            return
        fi
    fi
}
