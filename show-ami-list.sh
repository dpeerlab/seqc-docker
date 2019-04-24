#!/bin/bash

# special signature indicating that this is a SEQC AMI.
# do not change the value. this is being used in multiple repositories.
signature="708B13E3-3207-4C96-836B-E3AE591EEA47"

aws ec2 describe-images \
    --owner 583643567512 \
    --filters "Name=tag:Signature,Values=${signature}" \
    --query "Images[*].{ID:ImageId,Name:Name}"
