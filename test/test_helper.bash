#!/usr/bin/env bash

bats_log_status () {
    bats_log "status: $status"
    bats_log "output: $output"
}

init () {
    declare -gx BATS_LOGFILE
    BATS_LOGFILE="${BATS_DIRNAME:-${PWD}}/bats-$(date +%s).log"

    declare -gx DOTFILES_REPO_ROOT=''
    DOTFILES_REPO_ROOT="$(git rev-parse --show-toplevel)"
    : "${DOTFILES_REPO_ROOT:=${BATS_TEST_DIRNAME}/..}"

    export PATH="${DOTFILES_REPO_ROOT}:${PATH}"

    declare -gx DOTFILES_CONFIG_PATH="${BATS_DIRNAME}/fixtures/etc/dotfiles.conf"
    declare -gx DOTFILES_ENV="$DOTFILES_CONFIG_PATH"

    { set -- ; DOTFILES_AUTOMATED_TESTING=1 source "${DOTFILES_REPO_ROOT}/dotfiles" ; }

    if [[ "$BATS_LOG" -eq 1 ]]; then
        bats_log () {
            printf '[%s (%i)]: %s\n' "$BATS_TEST_NAME" "$BATS_TEST_NUMBER" "$*" >> "$BATS_LOGFILE"
        }
    else
        bats_log () { : ; }
    fi
}

init