#!/bin/bash

PROFILES=`grep profile ~/.aws/config  | awk '{print $2}' | sed s/\]//g`

for p in $PROFILES ; do
	echo "Generating credential report in $p"
	aws iam generate-credential-report --profile $p --output text
done