#!/bin/bash -e

hub="hisplan"
version="0.2.6-rc6"

echo "Packaging ${hub}/seqc:${version}..."

#
# tag it and push it to docker hub
#

docker login
docker tag seqc ${hub}/seqc:${version}
docker push ${hub}/seqc:${version}


#
# package it and push it to AWS S3
#

s3_dest="s3://dp-lab-home/software"

path_workdir=`mktemp -d`

tar cvzf ${path_workdir}/seqc-${version}.tar.gz \
    seqc-submit.sh seqc-progress.sh seqc_submit_mjobs.py show-ami-list.sh config/jobs.template.yml

aws s3 cp ${path_workdir}/seqc-${version}.tar.gz ${s3_dest}/

rm -rf ${path_workdir}
