#!/bin/bash

Ash__import "ghtools"

Ghtools__callable_main(){
    Ghtools__callable_help
}

Ghtools__callable_help(){
    Logger__log "TODO -- Help"
}

Ghtools__callable_labels(){
    Logger__prompt "Input the the repository to add labels (ex, carrot/ash-ghtools): "; read repo

    success=$(Ghtools_create_single_label "$repo" "wow" "ffffff")
    if [[ "$success" -eq "1" ]]; then
        echo "Success!"
    else
        echo "Failure!"
    fi
}
