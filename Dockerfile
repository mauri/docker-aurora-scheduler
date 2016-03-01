FROM dockerfile/java:oracle-java8

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
RUN echo "deb http://repos.mesosphere.io/ubuntu trusty main" >/etc/apt/sources.list.d/mesosphere.list

RUN apt-get update && apt-get install -y mesos=0.27.0-0.2.190.ubuntu1404

#ENV AURORA_REVISION 0.10.0-medallia-cmd

#RUN git clone https://github.com/medallia/aurora.git /aurora &&\
#	cd /aurora && \
#        git checkout ${AURORA_REVISION} &&\
#	./gradlew distZip && \
#        unzip -d /usr/local "/aurora/dist/distributions/aurora-scheduler-$(cat /aurora/.auroraversion).zip" &&\
#        cd / &&\ 
#        ln -s /usr/local/aurora-scheduler-$(cat /aurora/.auroraversion) /usr/local/aurora-scheduler &&\       
#        rm -rf /aurora
ADD build/aurora.deb /
RUN dpkg -i /aurora.deb

COPY /scheduler.sh /
#COPY lib /usr/lib

WORKDIR /

ENTRYPOINT ["/scheduler.sh"]
