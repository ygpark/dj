#!/bin/sh
[ "$1" = "." ] && echo $(pwd) && exit

if [ -f $1 ];then
	file=$(basename $1)
fi

if [ -d $1 ];then
	echo $(cd $1; pwd)
	exit
elif [ -f $1 ];then
	echo -n $(cd $(dirname $1); pwd)/
	echo $(basename $1)
fi

exit 0
