# run docker
#
# sshd_config -> disabled root login and password auth
# authorized_keys -> user 'node' uses authorized_keys
#
docker run -P -v `pwd`/authorized_keys:/home/node/.ssh/authorized_keys:ro -v `pwd`/sshd_config:/etc/ssh/sshd_config:ro -d hidehish/docker-node02
