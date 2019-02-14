# docker-seqc

## Building

```bash
$ docker build -t seqc .
```

## Running

Specify your own AWS EC2 keypair file for the `-k` parameter:

```bash
$ ./run-seqc-container.sh -k ~/dpeerlab-chunj.pem
```

Inside the container, run the following command to spawn a new EC2 instance:

```bash
$ SEQC start
```

```bash
$ SEQC run -h
```
