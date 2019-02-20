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

```bash
$ SEQC run in_drop_v2 \
    -o ./test \
    -i s3://seqc-public/genomes/hg38_chr19/ \
    --upload-prefix s3://dp-lab-home/chunj/seqc-test/out-in_drop_v2/ \
    --email jaeyoung.chun@gmail.com \
    -g s3://dp-lab-home/chunj/seqc-test/in_drop_v2/genomic/ \
    -b s3://dp-lab-home/chunj/seqc-test/in_drop_v2/barcode/ \
    --barcode-files s3://seqc-public/barcodes/in_drop_v2/flat/
```

### 10x v2

```bash
$ SEQC run ten_x_v2 \
    -o ./test \
    -i s3://seqc-public/genomes/hg38_chr19/ \
    --upload-prefix s3://dp-lab-home/chunj/seqc-test/out-ten_x_v2/ \
    --email jaeyoung.chun@gmail.com \
    -g s3://seqc-public/test/ten_x_v2/genomic/ \
    -b s3://seqc-public/test/ten_x_v2/barcode/ \
    --barcode-files s3://seqc-public/barcodes/ten_x_v2/flat/
```
