# vi: ts=4 sts=4 shiftwidth=4 expandtab 
# filename      : dj.sh
# DESCRIPTION   : Directory Jump
# AUTHOR        : Young-gi Park <ghostyak@gmail.com>
# VERSION       : v0.3
# HISTORY       : 
#   - 2013-07-02 (v0.1): first release 
#   - 2013-10-09 (v0.2): speed optimization
#   - 2014-02-23 (v0.3): refactoring & update display & keymap
#

## setting for the linux terminal
#CTRL+UP ,CTRL+LEFT, CTRL+RIGHT
bind '"\e[1;5A":"dj_ctrl_up\C-m"' 2> /dev/null
bind '"\e[1;5B":"dj_ctrl_down\C-m"' 2> /dev/null
bind '"\e[1;5C":"dj_ctrl_right\C-m"' 2> /dev/null
bind '"\e[1;5D":"dj_ctrl_left\C-m"' 2> /dev/null

## setting for the putty
#CTRL+UP ,CTRL+LEFT, CTRL+RIGHT
bind '"\eOA":"dj_ctrl_up\C-m"' 2> /dev/null
bind '"\eOB":"dj_ctrl_down\C-m"'  2> /dev/null
bind '"\eOC":"dj_ctrl_right\C-m"'  2> /dev/null
bind '"\eOD":"dj_ctrl_left\C-m"' 2> /dev/null

export DJ_FNAME_ABS=$HOME/.dj/dirlist
export DJ_FNAME_TEMP=$HOME/.dj/dirlist.tmp
export DJ_FNAME_SAVE=$HOME/.dj/dirlist.save
export DJ_FNAME_STACK=$HOME/.dj/dirlist.stack
export DJ_HOME=$(echo $HOME | sed 's/\//\\\//g')

#######################################################################################
function dj_print_usage
{
    echo "dj - Directory Jump";
    echo;
    echo "Usage: ";
    echo "    dj                 : print directories";
    echo "    dj [index]         : change directory by index";
    echo;
    echo "    dj add             : add current directory";
    echo "    dj add [dir]       : add directory";
    echo;
    echo "    dj rm              : remove current directory";
    echo "    dj rm [index]      : remove directory by index";
    echo;
    echo "    dj save <filename> : save dir list into the file";
    echo;
    echo "    dj load <filename> : load dir list from the file";
    echo;
    echo "    dj clean           : clean the stack";
    echo;
    echo "    dj help          : print usage";
    echo;
    echo "Key Map:";
    echo "       CTRL + UP          : display stored directoris";
    echo "       CTRL + LEFT        : change previous directory and display ";
    echo "       CTRL + RIGHT       : change next directory and display";
}
#######################################################################################

function dj_ctrl_up
{
    # clear stack
    rm -f $DJ_FNAME_STACK;

    # move previous directory
    clear;
    dj_prev;

    # print current dir list
    echo "[ Directory Jump ]";
    echo;
    dj_dirs;
    
    # delete last history
    history -d $(($HISTCMD-1));
}

function dj_ctrl_down
{
    # clear stack
    rm -f $DJ_FNAME_STACK;
    
    # move next directory
    clear;
    dj_next;

    # print current dir list
    echo "[ Directory Jump ]";
    echo;
    dj_dirs;

    # delete last history
    history -d $(($HISTCMD-1));
}

function dj_ctrl_left
{
    is_direct_line=0;
    is_diffrent_line=1;

    clear;

    # discards stack
    grep "$PWD" $DJ_FNAME_STACK > /dev/null 2>&1;
    if [ $? = $is_diffrent_line ]; then
        rm -f $DJ_FNAME_STACK;
    fi

    dj_push_dir_into_stack;

    # go down
    cd ..;

    # print current dir
    echo    "[ Directory Jump ]";
    echo;
    echo    "    TOP: `head -n1 $DJ_FNAME_STACK`";
    echo -e "    PWD: \033[7m$PWD\033[27m";
    echo;
    echo    "(See 'dj help' for for information)";
    echo;

    # delete last history
    history -d $(($HISTCMD-1));
}

function dj_ctrl_right
{
    clear;
    if [ -e $DJ_FNAME_STACK ]; then

        # go up
        cd $(tail -n1 $DJ_FNAME_STACK);

        # pop stack
        dj_pop_dir_from_stack;
    fi

    # print current dir
    echo "[ Directory Jump ]";
    echo;
    if [ -e $DJ_FNAME_STACK ]; then
        echo "    TOP: `head -n1 $DJ_FNAME_STACK`";
    else
        echo "    TOP: $PWD";
    fi
    echo -e "    PWD: \033[7m$PWD\033[27m";
    echo;
    echo "(See 'dj help' for for information)";
    echo;

    # delete last history
    history -d $(($HISTCMD-1));
}


# Brief: 
function dj_push_dir_into_stack
{
    if [ -e $DJ_FNAME_STACK ] \
        && [ $(tail -n1 $DJ_FNAME_STACK) != $PWD ] \
        && [ $PWD != "/" ]; then
        echo $PWD >> $DJ_FNAME_STACK;
    elif ! [ -e $DJ_FNAME_STACK ]; then
        echo $PWD >> $DJ_FNAME_STACK;
    fi
}

function dj_pop_dir_from_stack
{
    [ -e $DJ_FNAME_STACK ] && sed -i '$ d' $DJ_FNAME_STACK;
    ! [ -s $DJ_FNAME_STACK ] && rm $DJ_FNAME_STACK;
}

function dj_reload_only_exist_dir
{
    rm -f $DJ_FNAME_TEMP && touch $DJ_FNAME_TEMP;
    ! [ -f $DJ_FNAME_ABS ] && touch $DJ_FNAME_ABS;

    while read line; do
        if [ -d $line ]; then
            echo "$line" >> $DJ_FNAME_TEMP;
        fi
    done < <(cat $DJ_FNAME_ABS)

    mv $DJ_FNAME_TEMP $DJ_FNAME_ABS;
}

function dj_dirs
{
    LINE_COUNT=$(wc -l $DJ_FNAME_ABS | awk '{print $1}');
    if [ "$LINE_COUNT" == "0" ]; then
        echo "(empty stack. 'dj --help')";
        return;
    fi

    dj_reload_only_exist_dir;

    while read line;
    do
        directory=$(echo $line | awk '{print $2}');

        #Point out current directory
        if [[ $PWD == $directory ]];then
            echo -e "    \033[7m$line\033[27m";
        else
            echo "    $line";
        fi
    done < <(cat -n $DJ_FNAME_ABS)

    echo;
    echo "(See 'dj help' for for information)";
    echo;
}

function dj_add
{
    # Check param
    if ! test -d "$1"; then
        echo "error: Invalid parameter" 1>&2
        return 1;
    fi

    echo $(readlink -f $1) >> $DJ_FNAME_ABS;
    dj_reload_only_exist_dir;

    sort -u $DJ_FNAME_ABS -o $DJ_FNAME_TEMP;
    mv $DJ_FNAME_TEMP $DJ_FNAME_ABS;

    return;
}

function dj_clean
{
    rm -f $DJ_FNAME_ABS;
    touch $DJ_FNAME_ABS;
}

# Brief: Save a directory list to the filepath.
# Usage: dj_save <filepath>
function dj_save
{
    dj_reload_only_exist_dir;
    cp $DJ_FNAME_ABS $1;
}

# Brief: Load a directory list from the filepath.
# Usage: dj_load <filepath>
function dj_load
{
    cp $1 $DJ_FNAME_ABS;
    dj_reload_only_exist_dir;
    return 0;
}

# Brief: Remove a directory.
# Usage: dj_rm <filepath>
function dj_rm
{
    # Check argument whether number.
    if [ ! $(echo $1 | sed -n '/^[0-9]\+$/p') ]; then
        echo "error: Input number" 1>&2
        dj_print_usage;
        return;
    fi

    dj_reload_only_exist_dir;

    rm -f $DJ_FNAME_TEMP && touch $DJ_FNAME_TEMP;

    # Save all directoryes without target.
    while read line;
    do
        index=$(echo $line | awk '{print $1}');
        directory=$(echo $line | awk '{print $2}');
        [ "$index" -ne "$1" ] && echo $directory >> $DJ_FNAME_TEMP;
    done < <(cat -n $DJ_FNAME_ABS)

    mv $DJ_FNAME_TEMP $DJ_FNAME_ABS;

    return 0;
}

function dj_rm_by_dirname
{
    rm -f $DJ_FNAME_TEMP;
    touch $DJ_FNAME_TEMP;

    while read line;
    do
        if [[ ! "$line" == "$(readlink -f $1)" ]]; then
            echo "$line" >> $DJ_FNAME_TEMP;
        fi
    done < <(cat $DJ_FNAME_ABS)

    mv $DJ_FNAME_TEMP $DJ_FNAME_ABS;
}


function dj_next
{
    index_curr=0;

    dj_reload_only_exist_dir;

    while read line;
    do
        index=$(echo "$line" | awk '{print $1}')
        directory=$(echo $line | awk '{print $2}')

        if [[ $PWD == $directory ]];then
            index_curr=$index;
        fi
    done < <(cat -n $DJ_FNAME_ABS)

    index_curr=$(expr $index_curr + 1);
    index_end=$(wc -l $DJ_FNAME_ABS | awk '{print $1}');

    #roll back
    if [ $index_curr -gt $index_end ]; then
        index_curr=1;
    fi

    #change directory
    dj_go $index_curr;
    return 0;
}

function dj_prev
{
    index_curr=0;

    dj_reload_only_exist_dir;

    while read line;
    do
        index=$(echo $line | awk '{print $1}');
        directory=$(echo $line | awk '{print $2}');

        if [[ $PWD == $directory ]];then
            index_curr=$index;
        fi

    done < <(cat -n $DJ_FNAME_ABS)

    index_curr=$(expr $index_curr - 1);
    index_end=$(wc -l $DJ_FNAME_ABS | awk '{print $1}');

    #roll back
    if [ $index_curr -lt 1 ]; then
        index_curr=$index_end;
    fi

    #change directory
    dj $index_curr;
    return 0;
}

function dj_go
{
    # Check argument whether number.
    if [ ! $(echo $1 | sed -n '/^[0-9]\+$/p') ]; then
        dj_print_usage;
        return;
    fi

    DJ_TARGET=$(cat -n $DJ_FNAME_ABS | grep "^[[:space:]]*$1[[:space:]]" | awk '{print $2}');

    ! [ -z $DJ_TARGET ] && cd $DJ_TARGET;
}

function dj
{
    if [ ! -f $DJ_FNAME_ABS ]; then
        touch $DJ_FNAME_ABS
    fi

    case $1 in

        "")
            dj_dirs;
            ;;

    help)
        dj_print_usage;
        ;;

    add)
        if [ $# -gt 2 ]; then
            dj_print_usage;
            return;
        fi
        if [[ $# == 1 ]]; then
            dj_add "."
        else
            dj_add $2
        fi
        ;;

    rm)
        if [ $# -gt 2 ]; then
            dj_print_usage;
            return;
        elif [ $# -eq 1 ]; then
            dj_rm_by_dirname ".";
        elif [ $# -eq 2 ]; then
            dj_rm $2;
        fi
        ;;

    next)
        if [ $# -gt 1 ]; then
            dj_print_usage;
            return;
        fi
        dj_next $2;
        ;;

    prev)
        if [ $# -gt 1 ]; then
            dj_print_usage;
            return;
        fi
        dj_prev $2;
        ;;

    clean)
        if [ $# -gt 1 ]; then
            dj_print_usage;
            return;
        fi
        dj_clean;
        ;;

    save)
        if [ $# -gt 2 ]; then
            dj_print_usage;
            return;
        fi
        dj_save $2;
        ;;

    load)
        if [ $# -gt 2 ]; then
            dj_print_usage;
            return;
        fi
        dj_load $2;
        ;;

    *)
        dj_go $1
        ;;
        
    esac
}
