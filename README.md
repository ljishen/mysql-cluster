# mysql-cluster
![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/ljishen/mysql-cluster)
![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/ljishen/mysql-cluster)
![GitHub](https://img.shields.io/github/license/ljishen/mysql-cluster)

This image is packaged with [NDB Cluster Programs](https://dev.mysql.com/doc/refman/8.0/en/mysql-cluster-programs.html) not found in the [official mysql-cluster image](https://hub.docker.com/r/mysql/mysql-cluster).


![logo](https://www.mysql.com/common/logos/logo-mysql-170x115.png)

What is MySQL?
--------------

MySQL is the world's most popular open source database. With its proven performance, reliability, and ease-of-use, MySQL has become the leading choice of database for web applications of all sorts, ranging from personal websites and small online shops all the way to large-scale, high profile web operations like Facebook, Twitter, and YouTube.

For more information and related downloads for MySQL Server and other MySQL products, please visit <http://www.mysql.com>.


Supported Tags and Respective Dockerfile Links
----------------------------------------------

-   MySQL Cluster 8.0, the latest GA (tag: [`8.0`, `8.0.21`, `latest`](https://github.com/ljishen/mysql-cluster/blob/master/Dockerfile)) ([Dockerfile](https://github.com/ljishen/mysql-cluster/blob/master/Dockerfile))


How to Use the MySQL Cluster Image
----------------------------------

The instructions are similar to those for the official docker image: https://hub.docker.com/r/mysql/mysql-cluster. Specifically,

### Start a MySQL Cluster
```bash
$ git pull https://github.com/ljishen/mysql-cluster.git
$ cd mysql-cluster

$ docker network create mysql-cluster --subnet=192.168.0.0/16
$ docker run -d --net=mysql-cluster --name=management1 --ip=192.168.0.2 -v "$(pwd)"/cnf/mysql-cluster.cnf:/etc/mysql-cluster.cnf ljishen/mysql-cluster ndb_mgmd
$ docker run -d --net=mysql-cluster --name=ndb1 --ip=192.168.0.3 ljishen/mysql-cluster ndbd
$ docker run -d --net=mysql-cluster --name=mysql1 --ip=192.168.0.10 -e MYSQL_RANDOM_ROOT_PASSWORD=true ljishen/mysql-cluster mysqld
```

### Examine the Status of the Cluster
```bash
$ docker run --rm --net=mysql-cluster ljishen/mysql-cluster ndb_mgm -e show
[Entrypoint] MySQL Docker Image 8.0.20-1.1.16-cluster
[Entrypoint] Starting ndb_mgm
Connected to Management Server at: 192.168.0.2:1186
Cluster Configuration
---------------------
[ndbd(NDB)]     1 node(s)
id=2    @192.168.0.3  (mysql-8.0.20 ndb-8.0.20, Nodegroup: 0, *)

[ndb_mgmd(MGM)] 1 node(s)
id=1    @192.168.0.2  (mysql-8.0.20 ndb-8.0.20)

[mysqld(API)]   2 node(s)
id=3    @192.168.0.10  (mysql-8.0.20 ndb-8.0.20)
id=4 (not connected, accepting connect from 192.168.0.11)
```

### MySQL Login
```bash
$ docker exec -it mysql1 mysql -uroot -p"$(docker logs mysql1 2>&1 | grep -oP 'PASSWORD: \K.+')"
mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 55
Server version: 8.0.20-cluster MySQL Cluster Community Server - GPL

Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>
```

### Execute NDB Cluster Programs (Example: ndb_desc)

Suppose you have followed [these instructions](https://dev.mysql.com/doc/refman/8.0/en/mysql-cluster-disk-data-objects.html) and created a table named `dt_1` in database `test`:

```sql
CREATE TABLE dt_1 (
    member_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    dob DATE NOT NULL,
    joined DATE NOT NULL,
    INDEX(last_name, first_name)
    )
    TABLESPACE ts_1 STORAGE DISK
    ENGINE NDBCLUSTER;
```

```bash
$ docker run --rm --net=mysql-cluster --ip=192.168.0.11 ljishen/mysql-cluster ndb_desc -d test dt_1
[Entrypoint] MySQL Docker Image 8.0.20-1.1.16-cluster
-- dt_1 --
Version: 1
Fragment type: HashMapPartition
K Value: 6
Min load factor: 78
Max load factor: 80
Temporary table: no
Number of attributes: 5
Number of primary keys: 1
Length of frm data: 1002
Max Rows: 0
Row Checksum: 1
Row GCI: 1
SingleUserMode: 0
ForceVarPart: 1
PartitionCount: 1
FragmentCount: 1
PartitionBalance: FOR_RP_BY_LDM
ExtraRowGciBits: 0
ExtraRowAuthorBits: 0
TableStatus: Retrieved
Table options: readbackup
HashMap: DEFAULT-HASHMAP-3840-1
-- Attributes --
member_id Unsigned PRIMARY KEY DISTRIBUTION KEY AT=FIXED ST=MEMORY AUTO_INCR
last_name Varchar(200;utf8mb4_0900_ai_ci) NOT NULL AT=SHORT_VAR ST=MEMORY
first_name Varchar(200;utf8mb4_0900_ai_ci) NOT NULL AT=SHORT_VAR ST=MEMORY
dob Date NOT NULL AT=FIXED ST=DISK
joined Date NOT NULL AT=FIXED ST=DISK
-- Indexes -- 
PRIMARY KEY(member_id) - UniqueHashIndex
PRIMARY(member_id) - OrderedIndex
last_name(last_name, first_name) - OrderedIndex

NDBT_ProgramExit: 0 - OK
```
