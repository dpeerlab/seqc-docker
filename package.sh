#!/bin/bash

source config.sh

#
# tag it and push it to docker hub
#

echo "${registry}/${image_name}:${version}"

docker tag ${image_name}:${version} ${registry}/${image_name}:${version}
if [ $create_ecr_repo == 1 ]
then
    # only create if not exist
    aws ecr describe-repositories --repository-name ${image_name} 2> /dev/null
    if [ $? != 0 ]
    then
        aws ecr create-repository --repository-name ${image_name}
    fi
fi
docker push ${registry}/${image_name}:${version}

#
# package it and push it to AWS S3
#

s3_dest="s3://dp-lab-home/software"

path_workdir=`mktemp -d`

# create installation script
cat <<EOF > ${path_workdir}/install.sh
#!/bin/bash

aws s3 cp --quiet s3://dp-lab-home/software/seqc-${version}.tar.gz .
mkdir -p seqc-${version}
tar xzf seqc-${version}.tar.gz -C seqc-${version}

echo "DONE."
EOF

tar cvzf ${path_workdir}/seqc-${version}.tar.gz \
    seqc-submit.sh seqc-progress.sh seqc_submit_mjobs.py show-ami-list.sh config/jobs.template.yml config.sh

aws s3 cp ${path_workdir}/seqc-${version}.tar.gz ${s3_dest}/
aws s3 cp ${path_workdir}/install.sh ${s3_dest}/install-seqc-${version}.sh

rm -rf ${path_workdir}
