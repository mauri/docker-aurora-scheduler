FROM java:openjdk-8-jdk

COPY /usr /usr
COPY /scheduler.sh /
COPY /executor /opt/aurora/executors


ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

WORKDIR /

ENTRYPOINT ["/scheduler.sh"]

