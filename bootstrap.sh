#!/usr/bin/env bash
# vi: ts=4 sts=4 expandtab shiftwidth=4 
############################  SETUP PARAMETERS
app_name='dj'
bashrc_include='dj.sh'
git_uri='https://github.com/ygpark/dj'
git_branch='master'
debug_mode='1'

############################  BASIC SETUP TOOLS
msg() {
    printf '%b\n' "$1" >&2
}

success() {
    if [ "$ret" -eq '0' ]; then
        msg "\e[32m[✔]\e[0m ${1}${2}"
    fi
}

error() {
    msg "\e[31m[✘]\e[0m ${1}${2}"
    exit 1
}

debug() {
    if [ "$debug_mode" -eq '1' ] && [ "$ret" -gt '1' ]; then
        msg "An error occured in function \"${FUNCNAME[$i+1]}\" on line ${BASH_LINENO[$i+1]}, we're sorry for that."
    fi
}

program_exists() {
    local ret='0'
    type $1 >/dev/null 2>&1 || { local ret='1'; }

    # throw error on non-zero return value
    if [ ! "$ret" -eq '0' ]; then
        error "$2"
    fi
}

############################ SETUP FUNCTIONS

# Brief: make soft link if exist <src_dir>
# Usage: lnif <"src_dir"> <"dest_dir">
lnif() {
    if [ -e "$1" ]; then
        ln -sf "$1" "$2"
    fi
    ret="$?"
    debug
}

do_backup() {
    if [ -e "$2" ] || [ -e "$3" ] || [ -e "$4" ]; then
        today=`date +%Y%m%d_%s`
        for i in "$2" "$3" "$4"; do
            [ -e "$i" ] && [ ! -L "$i" ] && mv "$i" "$i.$today";
        done
        ret="$?"
        success "$1"
        debug
    fi
}

upgrade_repo() {
    msg "trying to update $1"
    cd "$HOME/.$app_name" &&
        git pull origin "$git_branch"

    ret="$?"
    success "$2"
    debug
}

clone_repo() {
    program_exists "git" "Sorry, we cannot continue without GIT, please install it first."
    endpath="$HOME/.$app_name"

    if [ ! -e "$endpath/.git" ]; then
        git clone --recursive -b "$git_branch" "$git_uri" "$endpath"
        ret="$?"
        success "$1"
        debug
    else
        upgrade_repo "$app_name"    "Successfully updated $app_name"
    fi
}


setup_bashrc() {

    is_include_exist_in_bashrc=$(grep "source ~/.$app_name/$bashrc_include" $HOME/.bashrc | wc -l)
    no="0"

    # .bashrc에 추가하기
    if [[ $is_include_exist_in_bashrc == $no ]]
    then
        echo "" >> ~/.bashrc
        echo "source ~/.$app_name/$bashrc_include" >> ~/.bashrc
        ret="$?"
        success "$1"
        debug
    else
        ret="0"
        success "$1"
        debug
    fi
}

source_bashrc() {
    [[ -e $HOME/.bashrc ]] && source $HOME/.bashrc
}

############################ SPECIAL FUNCTIONS


############################ MAIN()

program_exists "git" "To install $app_name you first need to install Git."

do_backup   "Your old git stuff has a suffix now and looks like $HOME/.$app_name.`date +%Y%m%d%S`" \
    "$HOME/.$app_name"

clone_repo      "Successfully cloned $app_name"

setup_bashrc "Successfully setup for '$HOME/.bashrc'"

msg             "\n * Type 'source $HOME/.bashrc' to finish the installation."
msg             " * Or installation is applied since next terminal."

msg             "\nThanks for installing $app_name."
msg             "© `date +%Y` $git_uri \n"





