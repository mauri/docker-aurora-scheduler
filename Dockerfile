FROM java:openjdk-8-jdk

RUN apt-get update && apt-get install -y git python-dev build-essential

ENV AURORA_REVISION 0.10.0-medallia-cmd

RUN git clone https://github.com/medallia/aurora.git /aurora &&\
	cd aurora && \
        git checkout ${AURORA_REVISION} &&\
	./gradlew distZip
RUN unzip -d /usr/local "aurora/dist/distributions/aurora-scheduler-$(cat aurora/.auroraversion).zip"
RUN ln -s /usr/local/aurora-scheduler-$(cat aurora/.auroraversion) /usr/local/aurora-scheduler
RUN rm -rf /aurora

COPY /scheduler.sh /

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

WORKDIR /

ENTRYPOINT ["/scheduler.sh"]
