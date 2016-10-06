FROM zer0touch/artifactory-base:latest

MAINTAINER Ryan Harper <ryanharper007@zer0touch.co.uk>

ADD run.sh /usr/local/bin/run
ADD storage.properties /artifactory/etc/storage.properties
ADD artifactory.lic /artifactory/etc/artifactory.lic
ADD artifactory.config.import.xml /artifactory/etc/artifactory.config.import.xml
ADD http://jdbc.postgresql.org/download/postgresql-9.3-1102.jdbc41.jar /tomcat/lib/postgresql-9.3-1102.jdbc41.jar
ADD https://dl.bintray.com/mitchellh/consul/0.4.1_linux_amd64.zip /consul.zip
ADD https://dl.bintray.com/mitchellh/consul/0.4.1_web_ui.zip /consul-ui.zip

RUN mv /var/lib/apt/lists* /tmp && \
    mv /var/cache/apt/archives/partial* /tmp && \
    apt-get update && \
    apt-get install --reinstall locales && \
    dpkg-reconfigure locales && \
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install postgresql-client sudo curl unzip openssl -y && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8 && \
    chmod +x /usr/local/bin/run && \
    mkdir /artifactory/etc && \
    unzip -d /usr/local/bin/ /consul.zip

VOLUME /consul-data
VOLUME /etc/consul.d

ADD ./services/artifactory.json /etc/consul.d/artifactory.json
ADD ./services/registry.json /etc/consul.d/registry.json
ADD ./server.xml /tomcat/conf/server.xml

VOLUME ["/var/lib/postgresql"]
EXPOSE 5432
EXPOSE 8081
CMD ["/usr/local/bin/run"]
