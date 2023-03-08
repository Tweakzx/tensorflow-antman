# 编译tensorflow源码的镜像
编译阿里巴巴开源的Antman中的tensorflow代码， 基础版本是1.15.4
由于antman的tensorflow直接编译遇到了一些不好解决的问题
所以我的编译方法是， 在测验成功编译tansorflow-1.15.4的代码中， 使用antman的代码进行了相应的替换， 重新编译。
结果是编译和安装可以顺利完成， 功能性的部分还未测验。

## 编译镜像
将 Dockerfile 放入到某个文件夹中， 进入这个文件夹
使用 docker build 来编译，自定义名称， 我的编译命令就是
```shell
docker build -t lzxcn/tf-antman:latest .
```

## 编译tensorflow
按照官方的编译流程编译
```shell
./configure
bazel build --config=opt //tensorflow/tools/pip_package:build_pip_package
pip install setuptools
./bazel-bin/tensorflow/tools/pip_package/build_pip_package /mnt
```

安装
``` shell
pip install protobuf==3.20.0
pip install /mnt/tensorflow-version-tags.whl
cd /tmp  # don't import from source directory
python -c "import tensorflow as tf; print(tf.__version__)"
```

## 注意事项
- github访问可能很慢， 可以利用Github520项目中的方法修改hosts， 多试几次
- 这只是一个提供编译环境的镜像， 如果需要编译tensorflow， 可以查看tensorflow的官方文档
- 如果想直接用， 可以访问[dockerhub](https://hub.docker.com/r/lzxcn/tf-antman), 几个tag的含义:
  - latest: 只有编译环境，tensorflow源码与antman版本源码， 没有编译过程中下载的依赖
  - alldown： 编译需要下载的依赖全部下载完成， 鉴于国内的网速， 依赖不是很好下载
  - srccmpd： tensorflow源码可以顺利编译成功
  - ulti： 将antman部分的代码替换到了tensorflow源码内之后，顺利编译成功并安装。 
  - github： 一个可能存在的版本，与github上的Dockerfile保持一致 
- alldown版本存在的numpy版本问题， 下降numpy版本到1.18.5之后， bazel clean， 重新./configure, bazel build
- 编译whl包需要pip下载setuptools
- 安装后要可以使用，需要保证protobuf版本为3.20.x, 建议在tensorflow安装前安装protobuf。

