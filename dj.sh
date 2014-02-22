# vi: ts=4 sts=4 shiftwidth=4 expandtab 
# FILENAME      : dj.sh
# DESCRIPTION	: Fast Change Directory by index
# AUTHOR        : Young-gi Park <ghostyak@gmail.com>
# VERSION       : v1.1
# HISTORY       : 
#   - 2013-07-02 (v1.0): first release 
#   - 2013-10-09 (v1.1): speed optimization


## setting for the linux terminal
#CTRL+UP ,CTRL+LEFT, CTRL+RIGHT
bind '"\e[1;5A":"dj_ctrl_up\C-m"' 2> /dev/null
bind '"\e[1;5D":"dj_ctrl_left\C-m"' 2> /dev/null
bind '"\e[1;5C":"dj_ctrl_right\C-m"' 2> /dev/null
bind '"\e[1;5B":"dj_ctrl_down\C-m"' 2> /dev/null

## setting for the putty
#CTRL+UP ,CTRL+LEFT, CTRL+RIGHT
bind '"\eOA":"dj_ctrl_up\C-m"' 2> /dev/null
bind '"\eOD":"dj_ctrl_left\C-m"' 2> /dev/null
bind '"\eOC":"dj_ctrl_right\C-m"'  2> /dev/null
 
export DJ_FNAME_ABS=$HOME/.dj/dirlist
export DJ_FNAME_REL=$HOME/.dj/dirlist.rel
export DJ_FNAME_TEMP=$HOME/.dj/dirlist.tmp
export DJ_FNAME_SAVE=$HOME/.dj/dirlist.save
export DJ_FNAME_HASH=$HOME/.dj/dirlist.hash
export DJ_FNAME_STACK=$HOME/.dj/dirlist.stack
export DJ_HOME=$(echo $HOME | sed 's/\//\\\//g')

#######################################
# migration area
#######################################
#function dj_migration
#{
#    echo $DJ_VERSION
#    if [[ "$DJ_VERSION" == "v1.0" ]]
#    then
#        cp $DJ_FNAME_ABS $DJ_FNAME_TEMP
#        sed -i "s/^~/$HOME/" $DJ_FNAME_TEMP
#    fi
#}
#
#dj_migration

#######################################
function dj_ctrl_up
{
    # clear stack
    rm -f $DJ_FNAME_STACK

    # move previous directory
    clear
    dj_prev

    # print current dir list
	echo "[ Directory Jump ]"
    echo
    dj_dirs
    
    # delete last history
    history -d $(($HISTCMD-1))
}

function dj_ctrl_down
{
    # clear stack
    rm -f $DJ_FNAME_STACK
    
    # move next directory
    clear
    dj_next

    # print current dir list
	echo "[ Directory Jump ]"
    echo
    dj_dirs

    # delete last history
    history -d $(($HISTCMD-1))
}

function dj_ctrl_left
{
    is_direct_line=0
    is_diffrent_line=1

    clear

    # discards stack
    grep "$PWD" $DJ_FNAME_STACK > /dev/null 2>&1
    if [ $? = $is_diffrent_line ]; then
        rm -f $DJ_FNAME_STACK
    fi

    dj_push_dir_into_stack

    # go down
    cd ..

    # print current dir
	echo "[ Directory Jump ]"
    echo
    echo "    TOP: `head -n1 $DJ_FNAME_STACK`"
    echo -e "    PWD: \033[7m$PWD\033[27m"
    echo
	echo "(See 'dj help' for for information)"
    echo

    # delete last history
    history -d $(($HISTCMD-1))
}

function dj_ctrl_right
{
    clear
    if [ -e $DJ_FNAME_STACK ]; then
        # go up
        cd $(tail -n1 $DJ_FNAME_STACK)

        # pop stack
        dj_pop_dir_from_stack
    fi

    # print current dir
	echo "[ Directory Jump ]"
    echo
    if [ -e $DJ_FNAME_STACK ]; then
        echo "    TOP: `head -n1 $DJ_FNAME_STACK`"
    else
        echo "    TOP: $PWD"
    fi
    echo -e "    PWD: \033[7m$PWD\033[27m"
    echo
	echo "(See 'dj help' for for information)"
    echo

    # delete last history
    history -d $(($HISTCMD-1))
}


# Brief: 
function dj_push_dir_into_stack {
    if [ -e $DJ_FNAME_STACK ] \
        && [ $(tail -n1 $DJ_FNAME_STACK) != $PWD ] \
        && [ $PWD != "/" ]
    then
        echo $PWD >> $DJ_FNAME_STACK
    elif ! [ -e $DJ_FNAME_STACK ]; then
        echo $PWD >> $DJ_FNAME_STACK
    fi
}

function dj_pop_dir_from_stack {
    [ -e $DJ_FNAME_STACK ] && sed -i '$ d' $DJ_FNAME_STACK
    ! [ -s $DJ_FNAME_STACK ] && rm $DJ_FNAME_STACK
}

function dj_print_usage
{
    echo "dj - Directory Jump"
    echo
    echo "Usage: "
    echo "	dj                 : print directories"
    echo "	dj [index]         : change directory by index"
    echo
    echo "	dj add             : add current directory"
    echo "	dj add [dir]       : add directory"
    echo
    echo "	dj rm              : remove current directory"
    echo "	dj rm [index]      : remove directory by index"
    echo
    echo "	dj save [filename] : save dir list into the file (default: $DJ_FNAME_SAVE)"
    echo
    echo "	dj load [filename] : load dir list from the file (default: $DJ_FNAME_SAVE)"
    echo
    echo "	dj clean           : clean the stack"
    echo
    echo "	dj help          : print usage"
    echo
    echo "Key Map:"
    echo "       CTRL + UP          : display stored directoris"
    echo "       CTRL + LEFT        : change previous directory and display "
    echo "       CTRL + RIGHT       : change next directory and display"
}

function dj_filter_real_path
{
	rm -f $DJ_FNAME_TEMP 
	touch $DJ_FNAME_TEMP

	while read line;
	do
		if [ -d $line ]; then
			echo "$line" >> $DJ_FNAME_TEMP
		fi
	done < <(cat $DJ_FNAME_ABS)

	mv $DJ_FNAME_TEMP $DJ_FNAME_ABS
}

function dj_dirs
{
	LINE_COUNT=$(wc -l $DJ_FNAME_REL | awk '{print $1}')
	if [ "$LINE_COUNT" == "0" ]; then
		echo "(empty stack. 'dj --help')"
		return;
	fi

	dj_filter_real_path
	dj_make_short_path

	while read line;
	do
		directory=$(echo $line | awk '{print $2}')

		#DJ_LONG_PATH=$(echo "$directory" | sed "s/^~/$DJ_HOME/")

		#Point out current directory
		if [[ $PWD == $directory ]];then
			echo -e "    \033[7m$line\033[27m"
		else
			echo "    $line"
		fi
	done < <(cat -n $DJ_FNAME_ABS)

	echo 
	echo "(See 'dj help' for for information)"
	echo 
}

function dj_add
{
	# Check param
	if ! test -d "$1"; then
		echo "error: Invalid parameter" 1>&2
		return 1;
	fi

	echo $(readlink -f $1) >> $DJ_FNAME_ABS
	dj_filter_real_path

	sort -u $DJ_FNAME_ABS -o $DJ_FNAME_TEMP 
	mv $DJ_FNAME_TEMP $DJ_FNAME_ABS

	dj_make_short_path
	return;
}

function dj_clean
{
	rm -f $DJ_FNAME_REL
	touch $DJ_FNAME_REL
}
 
function dj_save
{
	dj_filter_real_path

	if [ "$1" = "" ]; then
		cp $DJ_FNAME_ABS $DJ_FNAME_SAVE
		return 0;
	else 
		cp $DJ_FNAME_ABS $1
		return 0;
	fi
}
 
function dj_load
{
	rm -f $DJ_FNAME_TEMP 
	touch $DJ_FNAME_TEMP

	if test -f "$1" ; then
		cp $1 $DJ_FNAME_TEMP
        #to support the old version
        sed -i "s/^~/$DJ_HOME/" $DJ_FNAME_TEMP
		cp $DJ_FNAME_TEMP $DJ_FNAME_ABS
	else
		cp $DJ_FNAME_SAVE $DJ_FNAME_ABS
	fi

	dj_filter_real_path
	dj_make_short_path

    return 0;
}

function dj_make_short_path
{
	if ! test -f "$DJ_FNAME_HASH" 
	then
		sha1sum $DJ_FNAME_ABS > $DJ_FNAME_HASH
	fi

	if [[ "$(cat $DJ_FNAME_HASH)" == $(sha1sum $DJ_FNAME_ABS) ]]
	then
		return
	else
		cp $DJ_FNAME_ABS $DJ_FNAME_REL
		sed -i "s/^$DJ_HOME/~/" $DJ_FNAME_REL
		sha1sum $DJ_FNAME_ABS > $DJ_FNAME_HASH
	fi

	return 0;
}

 
function dj_rm
{
	# Check argument whether number.
	if [ ! $(echo $1 | sed -n '/^[0-9]\+$/p') ]; then
		echo "error: Input number" 1>&2
		dj_print_usage;
		return;
	fi

	dj_filter_real_path

	rm -f $DJ_FNAME_TEMP 
	touch $DJ_FNAME_TEMP

	while read line;
	do
		index=$(echo $line | awk '{print $1}')
		directory=$(echo $line | awk '{print $2}')

		if [ "$1" -ne "$index" ];then
			echo $directory >> $DJ_FNAME_TEMP
		fi

	done < <(cat -n $DJ_FNAME_ABS)

	mv $DJ_FNAME_TEMP $DJ_FNAME_ABS
	dj_make_short_path

	return 0;
}

function dj_rm_by_dirname
{
	rm -f $DJ_FNAME_TEMP
	touch $DJ_FNAME_TEMP

	while read line;
	do
		if [[ ! "$line" == "$(readlink -f $1)" ]]
		then
			echo "$line" >> $DJ_FNAME_TEMP
		fi
	done < <(cat $DJ_FNAME_ABS)


	mv $DJ_FNAME_TEMP $DJ_FNAME_ABS
	dj_make_short_path
}
 

function dj_next
{
	index_curr=0

	dj_filter_real_path
	dj_make_short_path
	
	while read line;
	do
		index=$(echo "$line" | awk '{print $1}')
		directory=$(echo $line | awk '{print $2}')

		if [[ $PWD == $directory ]];then
			index_curr=$index
		fi
	done < <(cat -n $DJ_FNAME_ABS)

	index_curr=$(expr $index_curr + 1)
	index_end=$(wc -l $DJ_FNAME_REL | awk '{print $1}')

	#roll back
	if [ $index_curr -gt $index_end ]; then
		index_curr=1
	fi

	#change directory
	dj_go $index_curr
	return 0;
}
 
function dj_prev
{
	index_curr=0

	dj_filter_real_path
	dj_make_short_path

	while read line;
	do
		index=$(echo $line | awk '{print $1}')
		directory=$(echo $line | awk '{print $2}')

		if [[ $PWD == $directory ]];then
			index_curr=$index
		fi

	done < <(cat -n $DJ_FNAME_ABS)

	index_curr=$(expr $index_curr - 1)
	index_end=$(wc -l $DJ_FNAME_REL | awk '{print $1}')

	#roll back
	if [ $index_curr -lt 1 ]; then
		index_curr=$index_end
	fi

	#change directory
	dj $index_curr
	return 0;
}

function dj_go
{
	# Check argument whether number.
	if [ ! $(echo $1 | sed -n '/^[0-9]\+$/p') ]; then
		dj_print_usage;
		return;
	fi

    DJ_TARGET=$(cat -n $DJ_FNAME_ABS | grep "^[[:space:]]*$1[[:space:]]" | awk '{print $2}')

    cd $DJ_TARGET
}

function dj
{
	if [ ! -f $DJ_FNAME_REL ]; then
		touch $DJ_FNAME_REL
	fi
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
			dj_rm_by_dirname "."
		elif [ $# -eq 2 ]; then
			dj_rm $2
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
