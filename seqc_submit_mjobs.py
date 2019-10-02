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


def pretty_print(path_ec2_keypair, platform, params):

    print("SEQC run {} \\".format(platform))

    # add the rest of the parameters
    line = ""
    for param in params:
        if str(param).startswith("--"):
            line += "  " + param
        else:
            line += " {} \\\n".format(param)

    # remove the last backslash
    print(line[:-2] + "\n")


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

        # `user-tags` requires a special treatment
        if key == "user-tags":
            if type(value) == str:
                # backward compatibility
                # if it's a string type, use as is
                # e.g. Job:2,Project:00000,Sample:DEV_IGO_00002
                params.append(value)
            elif type(value) == dict:
                # if it's a dictionary type, convert to a comma-separated key-value pair string
                # e.g.
                # user-tags:
                #   job: 1
                #   Project: Project_10178
                #   Sample: 1454_080119_CAFPDPN_P174_IGO_10178_21
                #
                # --> Job:1,Project:Project_10178,Sample:1454_080119_CAFPDPN_P174_IGO_10178_21
                params.append(
                    ",".join(list(f"{k}:{v}" for k, v in value.items()))
                )
            continue

        # to support those arguments that do not have any values
        # e.g. `--no-filter-low-coverage`
        if value:
            params.append(value)

    return platform, params


def main(path_yaml_input, path_ec2_keypair, ec2_keypair_name, is_dry_run):

    inputs = yaml.load(open(path_yaml_input))

    os.makedirs("logs", exist_ok=True)

    for input in inputs['jobs']:

        job_name = input["job"]

        platform, params = translate_params_yaml_to_list(input)

        path_log = os.path.join(
            "./logs/", "{}.log".format(
                job_name
            )
        )

        pretty_print(
            path_ec2_keypair,
            platform,
            params
        )

        # skip if dry run
        if is_dry_run:
            continue

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

    parser.add_argument(
        "--dry-run",
        action="store_true",
        dest="is_dry_run",
        help="Dry run (i.e. don't actually submit the job)"
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
        params.ec2_keypair_name,
        params.is_dry_run
    )
