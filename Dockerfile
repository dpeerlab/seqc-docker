FROM centos:7

LABEL maintainer="Jaeyoung Chun (chunj@mskcc.org)" \
      version.seqc="master" \
      version.star="2.5.3a" \
      version.samtools="1.3.1" \
      source.seqc="https://github.com/ambrosejcarr/seqc/tree/b7332d19823b92d76e32c8c2790ee1476b07c65f" \
      source.star="https://github.com/alexdobin/STAR/releases/tag/2.5.3a" \
      source.samtools="https://github.com/samtools/samtools/releases/tag/1.3.1"

ENV SEQC_VERSION b7332d19823b92d76e32c8c2790ee1476b07c65f
ENV MINICONDA_VERSION 4.5.1
ENV STAR_VERSION 2.5.3a
ENV SAMTOOLS_VERSION 1.3.1

ENV LC_ALL en_US.utf-8
ENV PATH="/opt/conda/bin:${PATH}"

# SEQC requires this
ENV TMPDIR "/tmp"

RUN yum group install -y "Development Tools" \
    && cd /tmp \
    && curl -O https://repo.anaconda.com/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh \
    && bash Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh -b -p /opt/conda \
    && rm -rf Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh \
    && ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh \
    && echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc

RUN cd /tmp \
    && curl -OL https://github.com/alexdobin/STAR/archive/${STAR_VERSION}.tar.gz \
    && tar -xf ${STAR_VERSION}.tar.gz \
    && cp STAR-${STAR_VERSION}/bin/Linux_x86_64_static/STAR /usr/bin/

RUN cd /tmp \
    && yum install -y zlib-devel ncurses-devel \
    && curl -OL https://github.com/samtools/samtools/releases/download/${SAMTOOLS_VERSION}/samtools-${SAMTOOLS_VERSION}.tar.bz2 \
    && tar xjvf samtools-${SAMTOOLS_VERSION}.tar.bz2 \
    && cd samtools-${SAMTOOLS_VERSION} \
    && make \
    && mv samtools /usr/bin/

# fixme: contact the author to release a tag and install a specific version
RUN pip install git+https://github.com/jacoblevine/phenograph.git

# fixme: contact the author to release a tag and install a specific version
# RUN cd /opt \
#     && yum install -y cairo cairo-devel cairomm-devel libjpeg-turbo-devel pango pango-devel pangomm pangomm-devel pigz \
#     && pip install Cython \
#     && pip install numpy \
#     && pip install bhtsne \
#     && git clone https://github.com/ambrosejcarr/seqc.git \
#     && cd seqc \
#     && sed -i 's/cairocffi>=0.8.0/cairocffi==0.8.0/' setup.py \
#     && sed -i 's/weasyprint/weasyprint==0.42.2/' setup.py \
#     && python setup.py install

RUN cd /opt \
    && yum install -y cairo cairo-devel cairomm-devel libjpeg-turbo-devel pango pango-devel pangomm pangomm-devel pigz \
    && pip install Cython \
    && pip install numpy \
    && pip install bhtsne \
    && curl -OL https://github.com/ambrosejcarr/seqc/archive/${SEQC_VERSION}.zip \
    && unzip ${SEQC_VERSION}.zip \
    && rm -rf ${SEQC_VERSION}.zip \
    && cd seqc-${SEQC_VERSION} \
    && sed -i 's/cairocffi>=0.8.0/cairocffi==0.8.0/' setup.py \
    && sed -i 's/weasyprint/weasyprint==0.42.2/' setup.py \
    && python setup.py install

RUN rm -rf /tmp/*

WORKDIR /root/

ENTRYPOINT ["SEQC"]
CMD ["-h"]

# install development tools which contains e.g. gcc
# install miniconda v4.5.1 which comes with Python 3.6.5 + pip
# install the SEQC dependencies

# seqc:setup.py
# the latest cairocffi v1.0.1 seems not compatible (as of 2019-02-13)
# requesting a specific version, namely v0.9.0 which also satisfies the Weasyprint requirements, seems to work

# update: 2019-02-20
# setup.py requires a specific version of cairocffi but not weasyprint which uses cairocffi.
# ensuring to install a specific version of weasyprint and cairocffi seems to resolve the issue
