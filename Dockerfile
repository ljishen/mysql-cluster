# Check the latest release for Linux at https://dev.mysql.com/downloads/cluster/
ARG MYSQL_CLUSTER_PACKAGE=mysql-cluster-8.0.20-linux-glibc2.12-x86_64

# This version should be the same as the version of the MYSQL_CLUSTER_PACKAGE
FROM mysql/mysql-cluster:8.0.20 AS builder
ARG  MYSQL_CLUSTER_PACKAGE
RUN yum install -y \
      tar \
      wget \
  && wget https://cdn.mysql.com/Downloads/MySQL-Cluster-8.0/$MYSQL_CLUSTER_PACKAGE.tar.gz \
  && tar -xf $MYSQL_CLUSTER_PACKAGE.tar.gz

WORKDIR /$MYSQL_CLUSTER_PACKAGE/bin

# Remove binaries that are already in the official image
RUN compgen -c | grep ndb | xargs rm -f


FROM mysql/mysql-cluster:8.0.20
ARG  MYSQL_CLUSTER_PACKAGE
COPY --from=builder /$MYSQL_CLUSTER_PACKAGE/bin/ndb* /usr/local/bin/
