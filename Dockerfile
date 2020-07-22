# Check the latest release for Linux at https://dev.mysql.com/downloads/cluster/
ARG MYSQL_CLUSTER_PACKAGE=mysql-cluster-8.0.21-linux-glibc2.12-x86_64

# We need libcrypto.so.1.1 and libssl.so.1.1 to run NDB cluster programs 
ARG OPENSSL_LIBS_PACKAGE=openssl11-libs-1.1.1c-2.el7.x86_64.rpm

# This version should be the same as the version of the MYSQL_CLUSTER_PACKAGE
FROM mysql/mysql-cluster:8.0.21 AS builder
ARG MYSQL_CLUSTER_PACKAGE
ARG OPENSSL_LIBS_PACKAGE
RUN yum install -y \
      tar \
      wget \
  && wget https://cdn.mysql.com/Downloads/MySQL-Cluster-8.0/$MYSQL_CLUSTER_PACKAGE.tar.gz \
  && tar -xf $MYSQL_CLUSTER_PACKAGE.tar.gz \
  && wget https://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/o/$OPENSSL_LIBS_PACKAGE

WORKDIR /$MYSQL_CLUSTER_PACKAGE/bin

# Remove binaries that are already in the official image
RUN compgen -c | grep ndb | xargs rm -f


FROM mysql/mysql-cluster:8.0.21
ARG  MYSQL_CLUSTER_PACKAGE
ARG OPENSSL_LIBS_PACKAGE
COPY --from=builder /$MYSQL_CLUSTER_PACKAGE/bin/ndb* /usr/local/bin/
COPY --from=builder /$OPENSSL_LIBS_PACKAGE /
RUN yum install -y $OPENSSL_LIBS_PACKAGE && rm $OPENSSL_LIBS_PACKAGE
