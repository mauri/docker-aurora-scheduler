FROM ubuntu:trusty

ARG AURORA_RELEASE=0.13.0-medallia
ARG GITHUB_AURORA_RELEASE=0.13.0-medallia-2

RUN apt-get update && \
	apt-get install -y software-properties-common && \
	add-apt-repository -y ppa:openjdk-r/ppa && \
	apt-get update && \
	apt-get install -y openjdk-8-jdk

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
RUN echo "deb http://repos.mesosphere.io/ubuntu trusty main" >/etc/apt/sources.list.d/mesosphere.list

RUN apt-get update && \
	apt-get install -y mesos=1.0.1-2.0.93.ubuntu1404 \
	ca-certificates \
	curl

RUN curl -L https://github.com/medallia/aurora/releases/download/${GITHUB_AURORA_RELEASE}/aurora-scheduler_${AURORA_RELEASE}_amd64.deb -o /aurora-scheduler.deb

RUN dpkg -i /aurora-scheduler.deb && rm /aurora-scheduler.deb

COPY /run.sh /

WORKDIR /

ENTRYPOINT ["/run.sh"]
