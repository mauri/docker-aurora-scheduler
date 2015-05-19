FROM java:openjdk-7-jdk

COPY /usr /usr
COPY /scheduler.sh /
COPY /executor /opt/aurora/executors


ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64

WORKDIR /

ENTRYPOINT ["/scheduler.sh"]

