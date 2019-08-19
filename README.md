Docker for a single node hadoop installation
============================================

This repository is used to create an hadoop single instance following the documentation on this page :
http://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/SingleCluster.html and the doc
of spark. This is a cloud-enabled docker image based on CentOS7, Spark and Zeppelin. For using the image, a docker enabled host (e.g. a VirtualBox, VMware oder Hyper-V virtual machine or AWS EC2 or OTC ECS) with at least 2 virtual CPU's/vCores, 4 GB memory and 16GB disk is recommended.

This image is not suitable for productive use, but offers the possibility to test the combination of Apache Spark and Apache Zeppelin for different possibilities.

Features :

* hadoop / hdfs
* yarn
* spark
* hive
* zeppelin

State of the project :

* Hadoop, yarn, spark, hive, zeppelin : running, not optimized. I'm interested by any feedback.


Docker basics on Amazon ECS
---------------------------

### Prepare your Amazon EC2 instance

If you are using Amazon EC2 already, you can launch an instance and install Docker to get started. 

1. Launch an instance with the Amazon Linux 2 AMI. 

2. Ensure/Modify the Security Group settings to allow access from 0.0.0.0/0 to your Amazon EC2 instance on TCP port 15000 for browser-based zeppelin access.

3. Connect to your instance. 
```bash
ssh -l ec2-user -i <local_path_to_your_AWS_keyfile>/<your_AWS_keyfile.pem> <Instance IP or FQDN> 
```

4. Update the installed packages and package cache on your instance: 
```bash
sudo yum update -y
```

5. Install the most recent Docker Community Edition package.
```bash
sudo yum install docker
```

6. Install docker compose
```bash
sudo curl -L https://github.com/docker/compose/releases/download/1.24.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo hmod +x /usr/local/bin/docker-compose
```

7. Install git
```bash
sudo yum install git
```

8. Start the Docker service.
```bash
sudo service docker start
```

9. Add the ec2-user to the docker group so you can execute Docker commands without using sudo. 
```bash
sudo usermod -a -G docker ec2-user
```

10. Log out and log back in again to pick up the new docker group permissions. You can accomplish this by closing your current SSH terminal window and reconnecting to your instance in a new one (see step 2). Your new SSH session will have the appropriate docker group permissions. 

11. Verify that the ec2-user can run Docker commands without sudo. 
```bash
docker info
```

Quickstart
----------

### clone the project

```bash
git clone https://github.com/tsi-martin/hadoop_demo.git
```

### create the container

```
cd hadoop_demo
docker-compose build
docker-compose up -d
```

### Zeppelin notebook

You can access to Zeppelin at http://<Instance IP or FQDN>:15000

### Check running container

```bash
docker ps
```

CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS                                                                                                                                                                                                NAMES
8045b913d054        hadoop_demo_hsn     "/root/start.sh"    37 minutes ago      Up 8 seconds        8020/tcp, 0.0.0.0:8088->8088/tcp, 0.0.0.0:9000->9000/tcp, 0.0.0.0:10020->10020/tcp, 0.0.0.0:15000->15000/tcp, 0.0.0.0:19888->19888/tcp, 8032/tcp, 0.0.0.0:50070->50070/tcp, 0.0.0.0:8002->8080/tcp   hadoop_demo_hsn_1


### Access container shell

```bash
docker exec -ti hadoop_demo_hsn_1 bash

