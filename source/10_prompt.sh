# Set colorful PS1 only on colorful terminals.
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS. Try to use the external file
# first to take advantage of user additions. Use internal bash
# globbing instead of external grep binary.
function set_prompts() {
    ## Solarized colors
    local BASE03=""
    local BASE02=""
    local BASE01=""
    local BASE00=""
    local BASE0=""
    local BASE1=""
    local BASE2=""
    local BASE3=""
    local YELLOW=""
    local ORANGE=""
    local RED=""
    local MAGENTA=""
    local VIOLET=""
    local BLUE=""
    local CYAN=""
    local GREEN=""

    local BOLD=""
    local RESET=""

    if tput setaf 1 &> /dev/null; then
        tput sgr0
        if [[ $(tput colors) -ge 256 ]] 2>/dev/null; then
            BASE03=$(tput setaf 234)
            BASE02=$(tput setaf 235)
            BASE01=$(tput setaf 240)
            BASE00=$(tput setaf 241)
            BASE0=$(tput setaf 244)
            BASE1=$(tput setaf 245)
            BASE2=$(tput setaf 254)
            BASE3=$(tput setaf 230)
            YELLOW=$(tput setaf 136)
            ORANGE=$(tput setaf 166)
            RED=$(tput setaf 160)
            MAGENTA=$(tput setaf 125)
            VIOLET=$(tput setaf 61)
            BLUE=$(tput setaf 33)
            CYAN=$(tput setaf 37)
            GREEN=$(tput setaf 64)
        else
            BASE03=$(tput setaf 8)
            BASE02=$(tput setaf 0)
            BASE01=$(tput setaf 10)
            BASE00=$(tput setaf 11)
            BASE0=$(tput setaf 12)
            BASE1=$(tput setaf 14)
            BASE2=$(tput setaf 7)
            BASE3=$(tput setaf 15)
            YELLOW=$(tput setaf 3)
            ORANGE=$(tput setaf 9)
            RED=$(tput setaf 1)
            MAGENTA=$(tput setaf 5)
            VIOLET=$(tput setaf 13)
            BLUE=$(tput setaf 4)
            CYAN=$(tput setaf 6)
            GREEN=$(tput setaf 2)
        fi
        BOLD=$(tput bold)
        RESET=$(tput sgr0)
    else
        BASE03="\e]P8002b36" # S_base03
        BASE02="\e]P0073642" # S_base02
        BASE01="\e]PA586e75" # S_base01
        BASE00="\e]PB657b83" # S_base00
        BASE3="\e]PFfdf6e3" # S_base3
        BASE2="\e]P7eee8d5" # S_base2
        BASE1="\e]PE93a1a1" # S_base1
        BASE0="\e]PC839496" # S_base0
        CYAN="\e]P62aa198" # S_cyan
        GREEN="\e]P2859900" # S_green
        MAGENTA="\e]P5d33682" # S_magenta
        RED="\e]P1dc322f" # S_red
        ORANGE="\e]P9cb4b16" # S_orange
        BLUE="\e]P4268bd2" # S_blue
        YELLOW="\e]P3b58900" # S_yellow
        VIOLET="\e]PD6c71c4" # S_violet

        echo -en $BASE03
        echo -en $BASE02
        echo -en $BASE01
        echo -en $BASE00
        echo -en $BASE3
        echo -en $BASE2
        echo -en $BASE1
        echo -en $BASE0
        echo -en $CYAN
        echo -en $GREEN
        echo -en $MAGENTA
        echo -en $RED
        echo -en $ORANGE
        echo -en $BLUE
        echo -en $YELLOW
        echo -en $VIOLET

        clear # against bg artifacts
        # Linux console colors. I don't have the energy
        # to figure out the Solarized values
        #YELLOW="\e[1;33m"
        #ORANGE="\033[1;33m"
        #RED="\e[1;31m"
        #MAGENTA="\033[1;31m"
        #VIOLET="\033[1;35m"
        #BLUE="\e[1;34m"
        #CYAN="\e[1;36m"
        #GREEN="\033[1;32m"
        #BOLD=""
        #RESET="\033[m"
    fi

    local PS1_user=""
    if [[ ${EUID} == 0 ]]; then
        PS1_user="\[${BOLD}${RED}\]\h"
    else
        PS1_user="\[${BOLD}${ORANGE}\]\u\[$BASE0\]@\[$YELLOW\]\h"
    fi
    local PS1_suff="\[$RESET$BLUE\] \w \$([[ \$? != 0 ]] && echo \"\[$RED\]:( \[$VIOLET\]\")\\$\[$RESET\] "
    PS1="$PS1_user$PS1_suff"

    ## Export the prompt
    export PS1
}

# sanitize TERM:
safe_term=${TERM//[^[:alnum:]]/?}
match_lhs=""

[[ -f ~/.dir_colors ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs} ]] \
    && type -P dircolors >/dev/null \
    && match_lhs=$(dircolors --print-database)

if [[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] ; then
    # we have colors :-)

    # Enable colors for ls, etc. Prefer ~/.dir_colors
    if type -P dircolors >/dev/null ; then
        if [[ -f ~/.dir_colors ]] ; then
            eval $(dircolors -b ~/.dir_colors)
        elif [[ -f /etc/DIR_COLORS ]] ; then
            eval $(dircolors -b /etc/DIR_COLORS)
        fi
    fi

    set_prompts
    unset set_prompts

    if [[ ! "$OSTYPE" =~ ^(darwin|freebsd) ]]; then
        alias ls="ls --color=auto"
        alias diff='colordiff'
        alias dir="dir --color=auto"
        alias grep="grep --color=auto"
        alias dmesg='dmesg --color'
    fi

else
    # show root@ when we do not have colors
    PS1="\u@\h \w \$([[ \$? != 0 ]] && echo \":( \")\$ "

    # Use this other PS1 string if you want \W for root and \w for all other users:
    # PS1="\u@\h $(if [[ ${EUID} == 0 ]]; then echo '\W'; else echo '\w'; fi) \$([[ \$? != 0 ]] && echo \":( \")\$ "

fi

# Try to keep environment pollution down, EPA loves us.
unset safe_term match_lh

PS2="> "
PS3="~ "
PS4="+ "
