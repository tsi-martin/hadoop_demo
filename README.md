Docker for a single node hadoop installation
============================================

This repository is used to create an hadoop single instance following the documentation on this page :
http://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/SingleCluster.html and the doc
of spark.

Features :

* hadoop / hdfs
* yarn
* spark
* hive
* zeppelin

State of the project :

* Hadoop, yarn, spark, hive, zeppelin : running, not optimized. I'm interested by any feedback.

Quickstart
----------

### clone the project

```bash
git clone https://github.com/tsi-martin/hadoop_demo.git
```

### create the container

```
docker-compose build
docker-compose up -d
```

### Zeppelin notebook

You can access to Zeppelin at http://localhost:15000

### Access container shell

```bash
docker exec -ti hadoop_demo_hsn bash

