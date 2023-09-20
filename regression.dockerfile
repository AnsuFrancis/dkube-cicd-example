FROM ubuntu:18.04

RUN apt-get update -y && DEBIAN_FRONTEND=noninteractive apt-get -y install git python-pip curl

RUN apt-get install -y python3.7 python3-distutils libpython3.7

#dcc
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && python3.7 get-pip.py && \
    rm get-pip.py && \
    pip install dkube-cicd-controller==1.6.0 setuptools==66.1.1 && \
    ln -s /usr/lib/x86_64-linux-musl/libc.so /lib/libc.musl-x86_64.so.1

#kubectl
RUN curl -LO https://dl.k8s.io/release/v1.20.0/bin/linux/amd64/kubectl
RUN mv kubectl /usr/local/bin/kubectl && chmod +x /usr/local/bin/kubectl

#conda
ENV PATH="/root/miniconda3/bin:${PATH}"
ARG PATH="/root/miniconda3/bin:${PATH}"
RUN apt-get update

RUN apt-get install -y wget && rm -rf /var/lib/apt/lists/*

RUN wget \
     https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
     && mkdir /root/.conda \
     && bash Miniconda3-latest-Linux-x86_64.sh -b \
     && rm -f Miniconda3-latest-Linux-x86_64.sh

ADD conda_env_regression.yaml .
RUN conda env create -f conda_env_regression.yaml && \
     conda clean -afy && conda init bash && \
     echo "source activate dkube-env" > ~/.bashrc

RUN touch /built_using_dockerfile
ENV PATH=/opt/conda/envs/dkube-env/bin:$PATH

ENV TINI_VERSION v0.16.1
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini

ENTRYPOINT [ "/usr/bin/tini", "--" ]


