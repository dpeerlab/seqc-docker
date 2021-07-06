#!/bin/bash

source config.sh

echo "Packaging seqc:${version}..."

tar cvzf seqc-${version}.tar.gz \
    seqc-submit.sh seqc-progress.sh seqc_submit_mjobs.py config/jobs.template.yml README.md

echo "To unpack:"
echo "tar xzf seqc-${version}.tar.gz -C seqc-${version}"
