#!/bin/bash

AUDITROLE="$1"
PAYER_PROFILE="$2"

if [ -z $AUDITROLE ] ; then
	echo "Usage: $0 <AUDITROLE>"
	exit 1
fi

# STEAMPIPE_INSTALL_DIR overrides the default steampipe directory of ~/.steampipe
if [ -z $STEAMPIPE_INSTALL_DIR ] ; then
  echo "STEAMPIPE_INSTALL_DIR not defined. Setting one"
  export STEAMPIPE_INSTALL_DIR=~/.steampipe
fi

# the AWS_CONFIG_FILE env variable overrides the default location for the ~/.aws/config file
if [ -z $AWS_CONFIG_FILE ] ; then
  echo "AWS_CONFIG_FILE not defined. Setting one"
  export AWS_CONFIG_FILE=~/.aws/config
fi

if [ ! -d $STEAMPIPE_INSTALL_DIR ] ; then
  echo "$STEAMPIPE_INSTALL_DIR doesn't exist. Creating it"
  mkdir -p ${STEAMPIPE_INSTALL_DIR}/config/
fi

if [ ! -f $AWS_CONFIG_FILE ] ; then
  echo "$AWS_CONFIG_FILE doesn't exist. Aborting"
  exit 1
fi

SP_CONFIG_FILE=${STEAMPIPE_INSTALL_DIR}/config/aws.spc
ALL_REGIONS='["*"]'

echo "Creating Steampipe Connections in $SP_CONFIG_FILE and AWS Profiles in $AWS_CONFIG_FILE"
echo "# Automatically Generated at `date`" > $SP_CONFIG_FILE
echo "# Automatically Generated at `date`" > $AWS_CONFIG_FILE

# Your AWS Config file needs a [default] section
echo <<EOF>>$AWS_CONFIG_FILE
[default]
region = us-east-1

EOF

cat <<EOF>>$SP_CONFIG_FILE

# Create an aggregator of _all_ the accounts as the first entry in the search path.
connection "aws" {
  plugin = "aws"
  type        = "aggregator"
  connections = ["aws_*"]
}

connection "aws_payer" {
  plugin = "aws"
  type        = "aggregator"
  connections = ["$PAYER_PROFILE"]
  regions = ["us-east-1"] # This aggregator is only used for global queries
}

EOF

# We now iterate across the `aws organizations list-accounts` command
while read line ; do

  # extract the values we need
  ACCOUNT_NAME=`echo $line | awk '{print $1}'`
  ACCOUNT_ID=`echo $line | awk '{print $2}'`

  # Steampipe doesn't like dashes, so we need to swap for underscores
  SP_NAME=`echo $ACCOUNT_NAME | sed s/-/_/g`

# Append an entry to the AWS Creds file
cat <<EOF>>$AWS_CONFIG_FILE

[profile $ACCOUNT_NAME]
role_arn = arn:aws:iam::$ACCOUNT_ID:role/$AUDITROLE
credential_source = Ec2InstanceMetadata
role_session_name = steampipe
EOF

# And append an entry to the Steampipe config file
cat <<EOF>>$SP_CONFIG_FILE
connection "aws_$SP_NAME" {
  plugin  = "aws"
  profile = "$ACCOUNT_NAME"
  regions = $ALL_REGIONS
    options "connection" {
        cache     = true # true, false
        cache_ttl = 3600  # expiration (TTL) in seconds
    }
}

EOF

done < <(aws organizations list-accounts --query Accounts[].[Name,Id,Status] --output text)

# All done!
exit 0