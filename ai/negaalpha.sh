#!/bin/sh

# Negaalpha search

set -e

usage() {
    echo "usage: $0 blokusfs_dir [depth]" 1>&2
    exit 1
}

negaalpha() { # args: node depth alpha beta
    if [ $2 -eq 0 ]; then
	read result < $1/value
    else
	local best=99999
	local alpha=$3
	local best_move
	local m
	cd -- $1
	for m in ????; do
	    if [ $m = "????" ]; then
		# no children - game end
		read result < value # FIXME: use score instead of value
		m="----"
	    else
		negaalpha $m $(($2 - 1)) $((- $4)) $((- $alpha))
	    fi
	    if [ $result -lt $best ]; then
		best=$result
		best_move=$m
		if [ $2 -eq $initial_depth ]; then echo $best_move $best 1>&2; fi
		if [ $result -lt $alpha ]; then
		    alpha=$result
		    if [ $alpha -le $4 ]; then
			result=$(($best * -1))
			cd ..
			return
		    fi
		fi
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

negaalpha "$dir" $initial_depth 99999 -99999
echo $result_move
