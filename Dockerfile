FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04

# install python 3.7 and pip

# apt-get update や apt-get upgrade の前に
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        software-properties-common \
        pkg-config \
        rsync \
        curl \
        git \
        unzip \
        zip \
        zlib1g-dev \
        wget \
        vim \
        npm \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        python3.7 python3.7-dev python3-pip python3.7-venv \
    && python3.7 -m pip install pip --upgrade \
    && python3.7 -m pip install six numpy==1.18.5 wheel mock \
    && python3.7 -m pip install keras_preprocessing --no-deps

RUN apt-get install -y  openjdk-8-jdk

RUN rm -rf /usr/bin/python \
    && ln -s /usr/bin/python3.7 /usr/bin/python

# Set up Bazel.

# Running bazel inside a `docker build` command causes trouble, cf:
#   https://github.com/bazelbuild/bazel/issues/134
# The easiest solution is to set up a bazelrc file forcing --batch.
# RUN echo "startup --batch" >>/etc/bazel.bazelrc
# Similarly, we need to workaround sandboxing issues:
#   https://github.com/bazelbuild/bazel/issues/418
# RUN echo "build --spawn_strategy=standalone --genrule_strategy=standalone" \
#    >>/etc/bazel.bazelrc
# Install the most recent bazel release.
# ENV BAZEL_VERSION 0.26.1

WORKDIR /

RUN npm install -g @bazel/bazelisk

#RUN mkdir /bazel && \
#    cd /bazel && \
#    curl -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36" -fSsL -O https://github.com/bazelbuild/bazel/releases/download/$BAZEL_VERSION/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh && \
#    curl -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36" -fSsL -o /bazel/LICENSE.txt https://raw.githubusercontent.com/bazelbuild/bazel/master/LICENSE && \
#    chmod +x bazel-*.sh && \
#    ./bazel-$BAZEL_VERSION-installer-linux-x86_64.sh && \
#    cd / && \
#    rm -f /bazel/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh


# Download and build TensorFlow.
ENV TENSORFLOW_VERSION v1.15.4
WORKDIR /
RUN git clone --branch=${TENSORFLOW_VERSION} --recurse-submodules  http://github.com/tensorflow/tensorflow.git
    
RUN git clone https://github.com/alibaba/GPU-scheduler-for-deep-learning.git

RUN cd tensorflow \
    && echo "0.26.1" > .bazelversion \
    && cd ..

RUN cd GPU-scheduler-for-deep-learning/TensorFlow-with-dynamic-scaling \
    && echo "0.26.1" > .bazelversion \
    && cd ..

# check for cuda, cudnn version
# docker run -it mytensorflow /bin/bash
# nvcc --version
# cat /usr/local/cuda/include/cudnn.h | grep CUDNN_MAJOR -A 2 cat /usr/include/cudnn.h | grep CUDNN_MAJOR -A 2

# Configure the build for our CUDA configuration.
ENV CI_BUILD_PYTHON python3.7
ENV LD_LIBRARY_PATH /usr/local/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH
ENV TF_NEED_CUDA 1
#ENV TF_NEED_TENSORRT 1
ENV TF_NEED_TENSORRT 0
#ENV TF_CUDA_COMPUTE_CAPABILITIES=3.5,5.2,6.0,6.1,7.0
ENV TF_CUDA_COMPUTE_CAPABILITIES=5.0
ENV TF_CUDA_VERSION=10.0
ENV TF_CUDNN_VERSION=7.6


#WORKDIR /tensorflow
#RUN yes '' | ./configure

RUN export LD_LIBRARY_PATH=/usr/local/cuda/lib64/stubs:$LD_LIBRARY_PATH \
    && ln -s /usr/local/cuda/lib64/stubs/libcuda.so /usr/local/cuda/lib64/stubs/libcuda.so.1 

#ENV TMP=/tmp
#RUN bazel build --config=opt --config=cuda //tensorflow:libtensorflow.so
