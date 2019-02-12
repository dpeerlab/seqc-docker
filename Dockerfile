FROM centos:7

LABEL maintainer="Jaeyoung Chun (chunj@mskcc.org)"

ENV MINICONDA_VERSION 4.5.1

RUN yum group install -y "Development Tools" \
    && cd \tmp \
    && curl -O https://repo.anaconda.com/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh \
    && bash Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh -b -p $HOME/miniconda \
    && rm -rf Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh \
    && echo 'export PATH="$HOME/miniconda/bin:$PATH"' >> ~/.bashrc \
    && source ~/.bashrc \
    && pip install Cython \
    && pip install numpy \
    && pip install bhtsne \
    && git clone https://github.com/ambrosejcarr/seqc.git \
    && cd seqc \
    && python setup.py install

ENTRYPOINT ["/root/miniconda/bin/SEQC"]
CMD ["-h"]

# install development tools which contains e.g. gcc
# install miniconda v4.5.1 which comes with Python 3.6.5 + pip
# install the SEQC dependencies
