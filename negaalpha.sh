#!/bin/sh
set -u
set -e

initial_depth=$2

negaalpha() { # args: node depth alpha beta
    if [ $2 -eq 0 ]; then
	read result < $1/value
    else
	local best=99999
	local alpha=$3
	local best_move
	local m
	cd $1
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

negaalpha $1 $initial_depth 99999 -99999
echo $result_move
