# docker-seqc

## Building

```bash
$ docker build -t seqc .
```

## Running

Specify your own AWS EC2 keypair file for the `-k` parameter:

```bash
$ ./console.sh -k ~/dpeerlab-chunj.pem
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
    -i s3://seqc-public/genomes/hg38_chr19/ \
    --barcode-files s3://seqc-public/barcodes/in_drop_v2/flat/
    -g s3://dp-lab-home/chunj/seqc-test/in_drop_v2/genomic/ \
    -b s3://dp-lab-home/chunj/seqc-test/in_drop_v2/barcode/ \
    --upload-prefix s3://dp-lab-home/chunj/seqc-test/in_drop_v2/seqc-results/ \
    -o ./test \
    --email jaeyoung.chun@gmail.com
```

### 10x v2

```bash
$ SEQC run ten_x_v2 \
    -i s3://seqc-public/genomes/hg38_long_polya/ \
    --barcode-files s3://seqc-public/barcodes/ten_x_v2/flat/
    -g s3://seqc-public/test/ten_x_v2/genomic/ \
    -b s3://seqc-public/test/ten_x_v2/barcode/ \
    --upload-prefix s3://dp-lab-home/chunj/seqc-test/out-ten_x_v2/seqc-results/ \
    -o ./test \
    --email jaeyoung.chun@gmail.com \
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
