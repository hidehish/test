# hidehish/docker-node02
# ref : https://www.docker.io/learn/dockerfile/level1/
# ret : http://www.infoq.com/jp/articles/docker-containers
#
# docker for developing Node.js + CoffeeScript + nodemon with NVM on Ubuntu
#

FROM ubuntu
RUN apt-get update
RUN apt-get install -y curl git man-db openssh-server rsync
RUN apt-get clean

RUN groupadd node
RUN useradd -s /bin/bash -m -g node -d /home/node node

RUN su -c "touch .profile" -l node
#
# install nvm 
RUN su -c "curl https://raw.github.com/creationix/nvm/master/install.sh | sh" -l node

# init ja_JP locale
RUN locale-gen ja_JP.UTF-8

# setup openssh-server
RUN mkdir /var/run/sshd
RUN echo "root:root" | chpasswd

# install Node.js
ENV NODE_JS_VERSION v0.10.25
RUN su -c "nvm install $NODE_JS_VERSION" -l node
RUN su -c "nvm alias default $NODE_JS_VERSION" -l node

# install npm libraries
# coffee-script, nodemon
RUN su -c "nvm use $NODE_JS_VERSION && npm install -g coffee-script nodemon" -l node

# http www and ssh port
EXPOSE 8080 22

# run sshd
CMD /usr/sbin/sshd -D
