FROM ubuntu:trusty
ARG AURORA_RELEASE
RUN apt-get update && apt-get install -y software-properties-common && \
	add-apt-repository -y ppa:webupd8team/java && \
	apt-get update 

RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections

RUN apt-get install -y oracle-java8-installer

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
RUN echo "deb http://repos.mesosphere.io/ubuntu trusty main" >/etc/apt/sources.list.d/mesosphere.list

RUN apt-get update && apt-get install -y mesos=0.27.0-0.2.190.ubuntu1404

ADD aurora-scheduler_${AURORA_RELEASE}_amd64.deb /

RUN dpkg -i /aurora-scheduler_${AURORA_RELEASE}_amd64.deb && rm /aurora-scheduler_${AURORA_RELEASE}_amd64.deb

COPY /scheduler.sh /

WORKDIR /

ENTRYPOINT ["/scheduler.sh"]
