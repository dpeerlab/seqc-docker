#!/usr/bin/env python

import yaml
import argparse
import os
import sys
import json
import subprocess


def run_command_detached(cmd):

    process = subprocess.Popen(
        cmd,
        close_fds=True
    )

    return process


def run_command(cmd, path_log):
    "run a command and return (stdout, stderr, exit code)"

    with open(path_log, "wb") as flog:
        process = subprocess.Popen(
            cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, shell=False
        )

        for line in iter(process.stdout.readline, b''):
            sys.stdout.write(line.decode(sys.stdout.encoding))
            flog.write(line)
            flog.flush()


def submit_job(path_ec2_keypair, platform, params, path_log):

    # construct SEQC run command
    cmd = [
        "./seqc-submit.sh", path_ec2_keypair, "run",
        platform
    ]

    # add the rest of the parameters
    cmd.extend(params)

    run_command(cmd, path_log)


def translate_params_yaml_to_list(job):

    platform = None

    params = list()

    for key, value in job.items():

        if key == "job":
            continue
        elif key == "platform":
            platform = value
            continue

        # `barcode-fastq` becomes `--barcode-fastq`
        # so that python argparse can parse properly
        params.append("--{}".format(key))

        # to support those arguments that do not have any values
        # e.g. `--no-filter-low-coverage`
        if value:
            params.append(value)

    return platform, params


def main(path_yaml_input, path_ec2_keypair, ec2_keypair_name):

    inputs = yaml.load(open(path_yaml_input))

    os.makedirs("logs", exist_ok=True)

    for input in inputs['jobs']:

        job_number = input["job"]

        platform, params = translate_params_yaml_to_list(input)        

        path_log = os.path.join(
            "./logs/", "{0}.{1:03d}.log".format(
                os.path.splitext(os.path.basename(path_yaml_input))[0],
                job_number
            )
        )

        print(path_log)
        print(yaml.dump(input, default_flow_style=False))

        # submit job
        submit_job(
            path_ec2_keypair,
            platform,
            params,
            path_log
        )

        print("--")


def parse_arguments():

    parser = argparse.ArgumentParser(description='submit_jobs')

    parser.add_argument(
        "--config", "-c",
        action="store",
        dest="path_yaml_input",
        help="path to jobs.yaml",
        required=True
    )

    parser.add_argument(
        "--pem", "-k",
        action="store",
        dest="path_ec2_keypair",
        help="path to AWS EC key pair file (*.pem)",
        required=True
    )

    parser.add_argument(
        "--key-name", "-n",
        action="store",
        dest="ec2_keypair_name",
        help="the name of your AWS EC2 key pair",
        required=False
    )

    # parse arguments
    params = parser.parse_args()

    # if ec2 key name not specified, extract from pem file name.
    if not params.ec2_keypair_name:
        params.ec2_keypair_name, _ = os.path.splitext(
            os.path.basename(params.path_ec2_keypair)
        )

    return params


if __name__ == "__main__":

    params = parse_arguments()

    main(
        params.path_yaml_input,
        params.path_ec2_keypair,
        params.ec2_keypair_name
    )
