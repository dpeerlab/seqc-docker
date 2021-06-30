#!/bin/bash

source version.sh

docker build -t seqc:${version} .
