#!/bin/bash

for TEST in `ls measurements`; do
	for DIR in rx tx; do
		for LEN in `ls measurements/$TEST/$DIR | sort -n`; do
			#echo -n -e "$TEST\t$DIR	$LEN	"
			grep 'main_thread.*[0-9]* pps' measurements/$TEST/$DIR/$LEN | awk '{printf ("%d\t%d\n", i++, $4);}'  | sed "s/.*/$TEST	$DIR	$LEN	&/g"
			#awk 'BEGIN{prev_test="none";}{ if (prev_test!="'$TEST'") { i=0 } printf("%s\t%s\t%d\t%d\t%d\n", "'$TEST'", "'$DIR'", '$LEN', ++i, $4 ); }'
		done
	done
done
