#!/bin/sh -xe

#
# main entry point to run s3cmd
#
S3CMD_PATH=/tmp/s3cmd/s3cmd

#
# Check for required parameters
#
if [ -z "${aws_key}" ]; then
    echo "The environment variable key is not set. Attempting to create empty creds file to use role."
    aws_key=""
fi

if [ -z "${aws_secret}" ]; then
    echo "The environment variable secret is not set."
    aws_secret=""
    security_token=""
fi

if [ -z "${cmd}" ]; then
    echo "ERROR: The environment variable cmd is not set."
    exit 1
fi

#
# Replace key and secret in the /.s3cfg file with the one the user provided
#
cd /tmp/s3cmd
export HOME='/tmp/s3cmd'
echo "" >> .s3cfg
echo "access_key = ${aws_key}" >> .s3cfg
echo "secret_key = ${aws_secret}" >> .s3cfg

if [ -z "${security_token}" ]; then
    echo "security_token = ${aws_security_token}" >> .s3cfg
fi

#
# Add region base host if it exist in the env vars
#
if [ "${s3_host_base}" != "" ]; then
  sed -i "s/host_base = s3.amazonaws.com/# host_base = s3.amazonaws.com/g" .s3cfg
  sed -i "s/host_bucket = %(bucket)s.s3.amazonaws.com/# host_bucket = %(bucket)s.s3.amazonaws.com/g" .s3cfg
  echo "host_base = ${s3_host_base}" >> .s3cfg
  echo "host_bucket = %(bucket)s.${s3_host_base}" >> .s3cfg
fi

if [ "${use_https}" != "" ]; then
  echo "use_https = ${use_https}" >> .s3cfg
fi

# Chevk if we want to run in interactive mode or not
if [ "${cmd}" != "interactive" ]; then

  #
  # sync-s3-to-local - copy from s3 to local
  #
  if [ "${cmd}" = "sync-s3-to-local" ]; then
      echo ${src-s3}
      ${S3CMD_PATH} --config=.s3cfg  sync ${SRC_S3} /tmp/dest/
  fi

  #
  # sync-local-to-s3 - copy from local to s3
  #
  if [ "${cmd}" = "sync-local-to-s3" ]; then
      ${S3CMD_PATH} --config=.s3cfg sync /tmp/src/ ${DEST_S3}
  fi
else
  tail -f /dev/null
fi


#
# Finished operations
#
echo "Finished s3cmd operations"
