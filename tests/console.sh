#!/bin/bash

usage()
{
cat << EOF
USAGE: `basename $0` [options]

    -k	absolute full path to AWS EC2 key pair (e.g. /home/chunj/dpeerlab-chunj.pem)

EOF
}

while getopts "k:h" OPTION
do
    case $OPTION in
        k) path_ec2_keypair=$OPTARG ;;        
        h) usage; exit 1 ;;
        *) usage; exit 1 ;;
    esac
done

if [ -z "$path_ec2_keypair" ]
then
    usage
    exit 1
fi

# extract only filename
filename_ec2_keypair=`python -c "import os; print(os.path.basename('$path_ec2_keypair'));"`

docker run \
    -it --rm \
    -e AWS_RSA_KEY=/root/${filename_ec2_keypair} \
    --mount source=${path_ec2_keypair},target=/root/${filename_ec2_keypair},type=bind \
    --mount source=~/.aws,target=/root/.aws,type=bind \
    --mount source=$(PWD)/install.sh,target=/root/install.sh,type=bind \
    --entrypoint bash \
    centos:7
