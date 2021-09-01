#!/bin/bash

source config.sh

docker_img_name="${registry}/${image_name}:${version}"

usage()
{
cat << EOF
USAGE: `basename $0` <ec2-key-pair> <command> [options]

EOF
}

path_ec2_keypair=${@:$OPTIND:1}
command=${@:$OPTIND+1:1}

if [ -z "$command" ] || [ -z "$path_ec2_keypair" ]
then
    usage;
    exit 1;
fi

shift
shift

# extract only filename
filename_ec2_keypair=`python -c "import os; print(os.path.basename('$path_ec2_keypair'));"`

docker run \
    -it --rm \
    -e AWS_RSA_KEY=/root/${filename_ec2_keypair} \
    --mount source=${path_ec2_keypair},target=/root/${filename_ec2_keypair},type=bind \
    --mount source=~/.aws,target=/root/.aws,type=bind \
    ${docker_img_name} ${command} $*
