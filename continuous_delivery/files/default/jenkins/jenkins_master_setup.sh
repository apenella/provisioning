#!/bin/bash

#
# definitions
DOCKER_HOST_GROUPNAME=docker
DOCKER_CONT_GROUPNAME="h_$DOCKER_HOST_GROUPNAME"
DOCKER_CONT_USER=jenkins
DOCKER_BIN=/usr/bin/docker
DOCKER_EXEC="exec -u root"
DOCKER_PS="ps -a"
DOCKER_CONT=jenkins-master

# check whether container exist
$DOCKER_BIN $DOCKER_PS | grep $DOCKER_CONT > /dev/null
if [ $? != 0 ]; then
        echo "ERROR: Container '$DOCKER_CONT' does not exist."
        exit 1
fi

# check whether user exists inside container
$DOCKER_BIN $DOCKER_EXEC $DOCKER_CONT grep $DOCKER_CONT_USER /etc/passwd > /dev/null
if [ $? != 0 ]; then
        echo "ERROR: User '$DOCKER_CONT_USER' does not exist on '$DOCKER_CONT' container."
        exit 1
fi

# achieve docker's group id from docker engine host
DOCKER_HOST_GID=`grep $DOCKER_HOST_GROUPNAME /etc/group | cut -d ":" -f3`
if [ -z $DOCKER_HOST_GID ]; then
        echo "ERROR: Group '$DOCKER_HOST_GROUPNAME' does not exist at host."
        exit 1
fi

# check whether exist a group with that group ID inside container
DOCKER_CONT_GID=`$DOCKER_BIN $DOCKER_EXEC $DOCKER_CONT grep $DOCKER_HOST_GID /etc/group`
# create a group with that group id inside container
if [ -z $DOCKER_CONT_GID ]; then
				# command to add new group
				GROUPADD_CMD="groupadd -g $DOCKER_HOST_GID $DOCKER_CONT_GROUPNAME"
				# command to add group to container user 
				USERMOD_CMD="usermod -aG $DOCKER_HOST_GID $DOCKER_CONT_USER"

        # create group
        $DOCKER_BIN $DOCKER_EXEC $DOCKER_CONT $GROUPADD_CMD
        if [ $? != 0 ]; then
                echo "ERROR: Command '$GROUPADD_CMD' finished with errors."
                exit 1
        fi
        # add group to user
        $DOCKER_BIN $DOCKER_EXEC $DOCKER_CONT $USERMOD_CMD
        if [ $? != 0 ]; then
                echo "ERROR: Command '$USERMOD_CMD' finished with errors."
                exit 1
        fi
else
        echo " GroupID $DOCKER_HOST_GID already exist. => $DOCKER_CONT_GID" 
fi
