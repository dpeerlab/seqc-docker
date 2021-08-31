#!/bin/bash -e

source config.sh

files="seqc-submit.sh seqc-progress.sh seqc_submit_mjobs.py show-ami-list.sh config/jobs.template.yml config.sh"
dest="$HOME/scing/bin"

usage()
{
cat << EOF
USAGE: `basename $0` [options]
    -d  destination (e.g. $HOME/scing/bin/)
    -s  AWS S3 destination; no trailing slash (e.g. s3://dp-lab-home/software)
EOF
}

while getopts "d:s:h" OPTION
do
    case $OPTION in
        d) dest=$OPTARG ;;
        s) s3_dest=$OPTARG ;;
        h) usage; exit 1 ;;
        *) usage; exit 1 ;;
    esac
done

if [ -z "$dest" ]
then
    usage
    exit 1
fi

# make destination directory if necessary
mkdir -p ${dest}

# create a temporary directory and copy files
path_workdir=`mktemp -d`
mkdir -p ${path_workdir}/seqc-${version}
rsync -Rv ${files} ${path_workdir}/seqc-${version}/

# tar-gzip
cd ${path_workdir}
tar cvzf ${dest}/seqc-${version}.tar.gz seqc-${version}/*

# deploy to AWS S3 if `s3_dest` is specified
if [ -n "$s3_dest" ]
then
    # create installation script
    cat <<EOF > ${path_workdir}/install.sh
#!/bin/bash

aws s3 cp --quiet ${s3_dest}/seqc-${version}.tar.gz .
tar xzf seqc-${version}.tar.gz

echo "DONE."
EOF

    aws s3 cp ${dest}/seqc-${version}.tar.gz ${s3_dest}/
    aws s3 cp ${path_workdir}/install.sh ${s3_dest}/install-seqc-${version}.sh

    echo "Installation:"
    echo "aws s3 cp ${s3_dest}/install-seqc-${version}.sh - | bash"
fi

# remove temporary directory
rm -rf ${path_workdir}

echo "DONE."
