#!/bin/sh

# Negamax search

set -e

usage() {
    echo "usage: $0 blokusfs_dir [depth]" 1>&2
    exit 1
}

negamax() { # args: node depth
    if [ $2 -eq 0 ]; then
	read result < $1/value
    else
	local best=99999
	local best_move
	local m
	cd -- $1
	for m in ????; do
	    if [ $m = "????" ]; then
		# no children - game end
		read result < value # FIXME: use score instead of value
		m="----"
	    else
		negamax $m $(($2 - 1))
	    fi
	    if [ $result -lt $best ]; then
		best=$result
		best_move=$m
		if [ $2 -eq $initial_depth ]; then echo $best_move $best 1>&2; fi
	    fi
	done
	cd ..
	result=$(($best * -1))
	result_move=$best_move
    fi
}

if [ "$1" != "" ]; then
    dir="$1"
else
    [ "$DIR" = "" ] && usage
    dir="$DIR"
fi
if [ ! -d "$dir" ]; then
    echo "$0: $dir is not a directory" 1>&2
    exit 1
fi

initial_depth=${2-2}

negamax "$dir" $initial_depth
echo $result_move
