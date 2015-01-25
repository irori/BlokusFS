#!/bin/sh
set -u
set -e

initial_depth=$2

negamax() { # args: node depth
    if [ $2 -eq 0 ]; then
	read result < $1/value
    else
	local best=99999
	local best_move
	local m
	cd $1
	for m in ????; do
	    negamax $m $(($2 - 1))
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

negamax $1 $initial_depth
echo $result_move
