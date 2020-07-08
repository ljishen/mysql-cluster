FROM oraclelinux:7-slim AS builder

# Check the latest release for Linux at https://dev.mysql.com/downloads/cluster/
ARG MYSQL_CLUSTER_PACKAGE=mysql-cluster-8.0.20-linux-glibc2.12-x86_64

RUN yum install -y \
      tar \
      gzip \
      wget \
  && wget https://cdn.mysql.com/Downloads/MySQL-Cluster-8.0/$MYSQL_CLUSTER_PACKAGE.tar.gz \
  && tar -xf $MYSQL_CLUSTER_PACKAGE.tar.gz


FROM mysql/mysql-cluster:8.0

COPY --from=builder /$MYSQL_CLUSTER_PACKAGE/bin /bin
