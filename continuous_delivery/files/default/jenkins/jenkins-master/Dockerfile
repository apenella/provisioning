FROM	jenkins/jenkins:lts
MAINTAINER	Aleix Penella (based on https://engineering.riotgames.com/)

# Using docker from Jenkins CI system container
# https://jpetazzo.github.io/2015/09/03/do-not-use-docker-in-docker-for-ci/

USER root

RUN	set -x && \
	apt-get update -y && \
	apt-get install -y \
	software-properties-common && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

RUN	mkdir /var/log/jenkins && \
	chown -R jenkins:jenkins /var/log/jenkins

USER jenkins

ENV	JAVA_OPTS="-Djenkins.install.runSetupWizard=false"
ENV	JENKINS_OPTS="--logfile=/var/log/jenkins/jenkins.log"

RUN	set -x && \
	/usr/local/bin/install-plugins.sh \
		generic-webhook-trigger \
		gitlab-plugin \
		workflow-job \
		workflow-multibranch \
		pipeline-model-definition \
		pipeline-multibranch-defaults \
		build-pipeline-plugin \
		pipeline-build-step \
		pipeline-stage-view \
		job-dsl \
		docker-plugin \
		docker-workflow \
		logstash