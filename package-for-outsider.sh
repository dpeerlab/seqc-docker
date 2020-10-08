#!/bin/bash

version="0.2.6"

echo "Packaging seqc:${version}..."

tar cvzf seqc-${version}.tar.gz \
    seqc-submit.sh seqc-progress.sh seqc_submit_mjobs.py config/jobs.template.yml instructions.md

echo "To unpack:"
echo "tar xzf seqc-${version}.tar.gz -C seqc-${version}"
