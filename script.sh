#!/bin/bash

# update ubuntu
sudo apt-get update
sudo apt-get install docker.io -y
echo "
FROM ubuntu

RUN apt-get update
RUN apt-get install nginx -y
EXPOSE 80

" >> Dockerfile
sudo docker build -t webserver .
sudo docker run -itd -p 80:80 --name mynginx webserver
sudo docker attach mynginx