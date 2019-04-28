#!/bin/bash

function fail() {
	echo "$*" 1>&2
	exit 1
}

[ $# -ne 1 ] && fail "usage: ./invalid_pps.sh {show|test}"
RUN_TESTS=0
[ $1 == "test" ] && RUN_TESTS=1
[ $1 == "show" ] && RUN_TESTS=0

./process_pps.sh | grep '	rx	' | \
while read LINE; do
	INVAL=0
	STDDEV=$( echo "$LINE" | awk '{print $7}')
	MIN=$( echo "$LINE" | awk '{print $4}')
	TEST=$( echo "$LINE" | awk '{print $1}')
	LEN=$( echo "$LINE" | awk '{print $3}')
	SAMPLES=$( echo "$LINE" | awk '{print $9}')

	DEPLOY=$( echo $TEST | sed 's/^lanner-//' | sed 's/-[0-9]*$//' )

	[[ $STDDEV -ge 10000 ]] && INVAL=1
	[[ $MIN -le 10000 ]] && INVAL=1
	[[ $SAMPLES -le 90 ]] && INVAL=1
	[[ $SAMPLES -ge 105 ]] && INVAL=1
	( echo "$LINE" | grep 9999999999 >/dev/null ) && INVAL=1

	[[ $INVAL -eq 1 ]] || continue
   
	echo "invalid measurement: $LINE"

	if [ $RUN_TESTS -eq 1 ]; then 
		ansible-playbook playbooks/deploy/$DEPLOY.yml || fail "ansible failed"
		./run_pps_test.sh $TEST $LEN
	fi
done
