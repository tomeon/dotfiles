#!/usr/bin/env bats

load test_helper

@test "dotfiles bombs out without a config repo given" {
    DOTFILES_CONFIG_REPO='' run dotfiles
    bats_log_status
    (( status == DOTFILES_EX_CONFIG ))
}
