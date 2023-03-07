# 编译tensorflow源码的镜像


# 编译方法
将 Dockerfile 放入到某个文件夹中， 进入这个文件夹
使用 docker build 来编译，自定义名称， 我的编译命令就是
```shell
docker build -t lzxcn/tf-antman:latest .
```

# 注意事项
- github访问可能很慢， 可以利用Github520项目中的方法修改hosts， 多试几次
- 这只是一个提供编译环境的镜像， 如果需要编译tensorflow， 可以查看tensorflow的官方文档
- 如果想直接用， 可以docker pull lzxcn/tf-antman:latest
