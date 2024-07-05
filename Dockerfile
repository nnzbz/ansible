# 基础镜像
FROM --platform=${TARGETPLATFORM} alpine:latest

# 如果这里不重复定义参数，后面会取不到参数的值
ARG VERSION

# 作者及邮箱
# 镜像的作者和邮箱
LABEL maintainer="nnzbz@163.com"
# 镜像的描述
LABEL description="集成了jupyter的ansible镜像"

USER root

# 设置工作目录
ENV WORKDIR=/usr/local/ansible
RUN mkdir -p ${WORKDIR}/data
WORKDIR ${WORKDIR}

# 更新软件
RUN apk update
RUN apk upgrade

# 设置时区
RUN apk add tzdata
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN echo "Asia/Shanghai" > /etc/timezone
RUN apk del tzdata

# 安装软件
RUN apk add --no-cache openssh-client python3 python3-dev gcc openssl-dev openssl libressl libc-dev linux-headers libffi-dev libxml2-dev libxml2 libxslt-dev g++
RUN apk add ansible
RUN apk add python3
RUN apk add py3-pip
RUN pip3 install jupyter; exit 0
# 下面是采用了国内镜像
#RUN pip3 install -i https://mirrors.aliyun.com/pypi/simple/ jupyter

# 删除缓存
RUN rm -rf /var/cache/apk/*

# 生成entrypoint.sh文件
RUN echo '#!/bin/sh' >> entrypoint.sh
RUN echo 'set +e' >> entrypoint.sh
RUN echo 'CMD="jupyter notebook --ip=0.0.0.0 --no-browser --allow-root --notebook-dir=${WORKDIR}/data --NotebookApp.base_url=${BASE_URL} ${CMD_ARGS}"' >> entrypoint.sh
RUN echo 'echo $CMD' >> entrypoint.sh
RUN echo 'exec $CMD' >> entrypoint.sh

# 授权执行
RUN chmod +x ./entrypoint.sh

# 执行
ENTRYPOINT ["sh", "./entrypoint.sh"]


