# docker-seqc

Dockerized SEQC

## Prerequisite

### Docker

Install [Docker](https://www.docker.com/get-started) version 2 (Engine version 18+). You need at least macOS Sierra 10.12 or newer macOS such as Mojave.

### Python

Have Python 3 on your computer.

### AWS Credentials

Skip if you're not going to have the SEQC to automatically launch the SEQC on an AWS EC2 instance. Otherwise, configure AWS credentials:

```bash
$ aws configure
```

Ensure the `.aws` directory (which contains your AWS credentials and configuration) is located at your home directory (e.g. `/home/john/.aws`)

Make sure your EC2 key pair file (*.pem) is NOT accessible by others. You can do this by running this command:

```bash
$ chmod 400 /path/my-key.pem
```

## How to Install

_Note that the steps described here are only tested on Mac._

Run the following commands from your Bash terminal:

```bash
aws s3 cp s3://dp-lab-home/software/install-seqc-0.2.9.sh - | bash
```

If you run `tree`, you should see something like this:

```bash
$ tree
.
├── config
│   └── jobs.template.yml
├── seqc-submit.sh
├── seqc_submit_mjobs.py
└── show-ami-list.sh

1 directory, 4 files
```

## How to Submit Multiple Jobs to AWS (Multiple Samples)

### Input Configuration

Jump start by duplicating the template:

```bash
$ cp config/jobs.template.yml config/jobs.yml
```

Edit `jobs.yml`:

```bash
$ nano config/jobs.yml
```

```yaml
jobs:
  - job: 1
    ami-id: ${PLACE_AMI_ID_HERE}
    platform: ten_x_v2
    user-tags:
      Job: 1
      Project: 10178
      Sample: DEV_IGO_00001
    index: s3://seqc-public/genomes/hg38_long_polya/
    barcode-files: s3://seqc-public/barcodes/ten_x_v2/flat/
    genomic-fastq: s3://seqc-public/test/ten_x_v2/genomic/
    barcode-fastq: s3://seqc-public/test/ten_x_v2/barcode/
    upload-prefix: s3://dp-lab-home/chunj/seqc-test/ten_x_v2/seqc-results/
    output-prefix: test1
    email: jaeyoung.chun@gmail.com
    star-args: "runRNGseed=0"
  - job: 2
    ami-id: ${PLACE_AMI_ID_HERE}
    platform: ten_x_v2
    user-tags:
      Job: 2
      Project: 10178
      Sample: DEV_IGO_00002
    index: s3://seqc-public/genomes/hg38_long_polya/
    barcode-files: s3://seqc-public/barcodes/ten_x_v2/flat/
    genomic-fastq: s3://seqc-public/test/ten_x_v2/genomic/
    barcode-fastq: s3://seqc-public/test/ten_x_v2/barcode/
    upload-prefix: s3://dp-lab-home/chunj/seqc-test/ten_x_v2/seqc-results/
    output-prefix: test2
    email: jaeyoung.chun@gmail.com
    star-args: "runRNGseed=0"
```

Note that you must specify which SEQC AMI (Amazon Machine Image) to use via `ami-id`. If you do not know the AMI ID, you can run `show-ami-list.sh`. The recommended AMI (as of October 24, 2020) is `ami-0bfdaae9bb0af465e`.

```bash
$ ./show-ami-list.sh
[
    {
        "ID": "ami-0530a8e9d69e60500",
        "Name": "seqc-v0.2.4_a1"
    },
    {
        "ID": "ami-05fd54e8d80f2665f",
        "Name": "seqc-v0.2.3-alpha.5_a1"
    },
    {
        "ID": "ami-0a4d2955fe21dee72",
        "Name": "seqc-v0.2.5_a2"
    },
    {
        "ID": "ami-0c97def6c08694a9a",
        "Name": "seqc-v0.2.9_a1"
    },
    {
        "ID": "ami-0f7bddb56c574069c",
        "Name": "seqc-v0.2.7_a3"
    }
]
```

If you want to specify any of the SEQC parameters, you can add a new line to the job description using the same format. For example, to specify `--min-poly-t=0` and `--no-filter-low-coverage`, add the following two lines:

```yaml
min-poly-t: "0"
no-filter-low-coverage: ""
```

### Job Submission

```bash
$ python seqc_submit_mjobs.py --help
usage: seqc_submit_mjobs.py [-h] --config PATH_YAML_INPUT --pem
                            PATH_EC2_KEYPAIR [--key-name EC2_KEYPAIR_NAME]
                            [--dry-run]

optional arguments:
  -h, --help            show this help message and exit
  --config PATH_YAML_INPUT, -c PATH_YAML_INPUT
                        path to jobs.yaml
  --pem PATH_EC2_KEYPAIR, -k PATH_EC2_KEYPAIR
                        path to AWS EC key pair file (*.pem)
  --key-name EC2_KEYPAIR_NAME, -n EC2_KEYPAIR_NAME
                        the name of your AWS EC2 key pair
  --dry-run             Dry run (i.e. don't actually submit the job)
```

```bash
$ python seqc_submit_mjobs.py \
    --pem ~/dpeerlab-chunj.pem \
    --config config/jobs.yml
```

```
2020-10-07 20:09:10,083 - INFO - Starting...
2020-10-07 20:09:10,086 - INFO - JOB NAME=PBMC1k-10x-v3, LOG FILE=./logs/PBMC1k-10x-v3.log
SEQC run ten_x_v3 \
  --ami-id ami-07ef40419e641a43c \
  --user-tags Job:PBMC1k-10x-v3,Project:v0.2.7,Sample:PBMC1k-10x-v3 \
  --index s3://seqc-public/genomes/hg38_long_polya/ \
  --barcode-files s3://seqc-public/barcodes/ten_x_v3/flat/ \
  --genomic-fastq s3://dp-lab-test/seqc/datasets/PBMC-1k-10x-v3/genomic/ \
  --barcode-fastq s3://dp-lab-test/seqc/datasets/PBMC-1k-10x-v3/barcode/ \
  --upload-prefix s3://dp-lab-test/seqc/datasets/PBMC-1k-10x-v3/seqc-results/ \
  --output-prefix v0.2.7 \
  --no-filter-low-coverage \
  --min-poly-t 0 \
  --email jaeyoung.chun@gmail.com \
  --star-args runRNGseed=0
2020-10-07 20:09:10,086 - INFO - Submitting a job...
2020-10-07 20:09:18,550 - INFO - Cleaning up the unused security groups:
2020-10-07 20:09:18,573 - INFO - SEQC: 2020-10-08 00:09:18: writing script to file:
2020-10-07 20:09:18,573 - INFO - #!/bin/bash -x
2020-10-07 20:09:18,573 - INFO -
2020-10-07 20:09:18,573 - INFO - SEQC run ten_x_v3 --ami-id ami-07ef40419e641a43c --user-tags Job:PBMC1k-10x-v3,Project:v0.2.7,Sample:PBMC1k-10x-v3 --index s3://seqc-public/genomes/hg38_long_polya/ --barcode-files s3://seqc-public/barcodes/ten_x_v3/flat/ --genomic-fastq s3://dp-lab-test/seqc/datasets/PBMC-1k-10x-v3/genomic/ --barcode-fastq s3://dp-lab-test/seqc/datasets/PBMC-1k-10x-v3/barcode/ --upload-prefix s3://dp-lab-test/seqc/datasets/PBMC-1k-10x-v3/seqc-results/ --output-prefix v0.2.7 --no-filter-low-coverage --min-poly-t 0 --email jaeyoung.chun@gmail.com --star-args runRNGseed=0 --local --terminate
2020-10-07 20:09:18,573 - INFO -
2020-10-07 20:09:18,752 - INFO - SEQC: 2020-10-08 00:09:18: Created new security group: sg-0e8190b78d1e639bf (name=SEQC-1941258).
2020-10-07 20:09:19,593 - INFO - SEQC: 2020-10-08 00:09:19: Enabled ssh access via port 22 for security group sg-0e8190b78d1e639bf
2020-10-07 20:09:21,255 - INFO - SEQC: 2020-10-08 00:09:21: Instance i-08a1eff31d49c1631 created, waiting until running
2020-10-07 20:09:36,528 - INFO - SEQC: 2020-10-08 00:09:36: Instance i-08a1eff31d49c1631 in running state
2020-10-07 20:09:36,715 - INFO - SEQC: 2020-10-08 00:09:36: Connecting to instance i-08a1eff31d49c1631 via ssh
2020-10-07 20:10:08,049 - INFO - SEQC: 2020-10-08 00:10:08: Formatting and mounting /dev/xvdf to /home/ec2-user
2020-10-07 20:10:10,329 - INFO - SEQC: 2020-10-08 00:10:10: Successfully mounted new volume onto /home/ec2-user.
2020-10-07 20:10:10,330 - INFO - SEQC: 2020-10-08 00:10:10: Setting aws credentials.
2020-10-07 20:10:32,778 - INFO - SEQC: 2020-10-08 00:10:32: SEQC setup complete.
2020-10-07 20:10:32,854 - INFO - SEQC: 2020-10-08 00:10:32: Instance login: ssh -i <path to your key file> ec2-user@3.234.220.98
2020-10-07 20:10:32,854 - INFO - SEQC: 2020-10-08 00:10:32: Connecting to instance i-08a1eff31d49c1631 via ssh
2020-10-07 20:10:33,871 - INFO -
2020-10-07 20:10:33,871 - INFO - DONE.
```

## Single-Nucleus RNA Sequencing

Everything is the same except the following three lines in YAML:

For human (hg38):

```yaml
  index: s3://seqc-public/genomes/hg38_long_polya_snRNAseq/
  filter-mode: snRNA-seq
  max-insert-size: 2304700
```

For mouse (mm38):

```yaml
  index: s3://seqc-public/genomes/mm38_long_polya_snRNAseq/
  filter-mode: snRNA-seq
  max-insert-size: 4434881
```

## How to Submit a Single Job to AWS (Single Sample)

```bash
$ ./seqc-submit.sh ~/dpeerlab-chunj.pem run ten_x_v2 \
    --index s3://seqc-public/genomes/hg38_long_polya/ \
    --barcode-files s3://seqc-public/barcodes/ten_x_v2/flat/ \
    --genomic-fastq s3://seqc-public/test/ten_x_v2/genomic/ \
    --barcode-fastq s3://seqc-public/test/ten_x_v2/barcode/ \
    --upload-prefix s3://dp-lab-home/chunj/seqc-test/ten_x_v2/seqc-results/ \
    --output-prefix test \
    --ami ami-05fd54e8d80f2665f \
    --email jaeyoung.chun@gmail.com
```

## Checking Progress

Run the following command to see the log message in real time:

```bash
$ ./seqc-progress.sh ~/dpeerlab-chunj.pem i-0fbffa334be875092
```

If the instance has already been stopped/terminated, you will see:

```
socket.gaierror: [Errno -2] Name or service not known
```

If the instance is not fully up and running, you will see:

```
ChildProcessError: cat: ./seqc_log.txt: No such file or directory
```

## Development

### Building Docker Images

Building local image:

```bash
$ ./build.sh
```

Building Cromwell-compatible image:

```bash
$ ./package-for-cromwell.sh
```

Bulding a deployable package for external users:

```bash
$ ./package-for-outsider.sh
```

### Debugging through Console

Specify your own AWS EC2 keypair file for the `-k` parameter:

```bash
$ ./console.sh -k ~/dpeerlab-chunj.pem -d
```

Inside the container, run the following command to spawn a new EC2 instance:

```bash
$ SEQC start
```

### Testing

#### In Drop v2

Inside the container

```bash
$ SEQC run in_drop_v2 \
    --index s3://seqc-public/genomes/hg38_chr19/ \
    --barcode-files s3://seqc-public/barcodes/in_drop_v2/flat/ \
    --genomic-fastq s3://dp-lab-home/chunj/seqc-test/in_drop_v2/genomic/ \
    --barcode-fastq s3://dp-lab-home/chunj/seqc-test/in_drop_v2/barcode/ \
    --upload-prefix s3://dp-lab-home/chunj/seqc-test/in_drop_v2/seqc-results/ \
    --output-prefix test \
    --email jaeyoung.chun@gmail.com
```

#### 10x v2 Chemistry

```bash
$ SEQC run ten_x_v2 \
    --index s3://seqc-public/genomes/hg38_long_polya/ \
    --barcode-files s3://seqc-public/barcodes/ten_x_v2/flat/ \
    --genomic-fastq s3://seqc-public/test/ten_x_v2/genomic/ \
    --barcode-fastq s3://seqc-public/test/ten_x_v2/barcode/ \
    --upload-prefix s3://dp-lab-home/chunj/seqc-test/ten_x_v2/seqc-results/ \
    --output-prefix test \
    --email jaeyoung.chun@gmail.com
```

#### 10x v3 Chemsitry

```bash
$ SEQC run ten_x_v3 \
    --index s3://seqc-public/genomes/hg38_long_polya/ \
    --barcode-files s3://seqc-public/barcodes/ten_x_v3/flat/ \
    --genomic-fastq s3://dp-lab-home/chunj/seqc-test/ten_x_v3/genomic/ \
    --barcode-fastq s3://dp-lab-home/chunj/seqc-test/ten_x_v3/barcode/ \
    --upload-prefix s3://dp-lab-home/chunj/seqc-test/ten_x_v3/seqc-results/ \
    --output-prefix test \
    --email jaeyoung.chun@gmail.com
```

#### Local Unit Testing

```bash
$ docker run \
    -it --rm \
    --mount source=~/.aws,target=/root/.aws,type=bind \
    --entrypoint bash \
    seqc
```

Once you're inside the container, run the following command:

```bash
$ nose2 seqc.test.TestSEQC.test_local
```
