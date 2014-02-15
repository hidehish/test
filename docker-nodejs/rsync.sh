# rsync ./src to /home/node/src
rsync -e "ssh -p 49200 -i $DOCKER_SSH_KEY_PATH" -v -ru ./src/ node@localhost:/home/node/src/
