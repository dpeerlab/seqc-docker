# docker-seqc

## Building

```bash
$ docker build -t seqc .
```

## Running Examples

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

## Debugging through Console

Specify your own AWS EC2 keypair file for the `-k` parameter:

```bash
$ ./console.sh -k ~/dpeerlab-chunj.pem -d
```

Inside the container, run the following command to spawn a new EC2 instance:

```bash
$ SEQC start
```

## Testing

### In Drop v2

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

### 10x v2 Chemistry

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

### 10x v3 Chemsitry

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

### Local Unit Testing

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
