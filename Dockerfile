FROM oraclelinux:7-slim

MAINTAINER Lagutin R.A. <rlagutin@mta4.ru>

ARG JENKINS_USER
ARG JENKINS_GROUP
ARG JENKINS_HOME
ARG JENKINS_UID
ARG JENKINS_GID

ENV JENKINS_USER=${JENKINS_USER:-jenkins} \
    JENKINS_GROUP=${JENKINS_GROUP:-jenkins} \
    JENKINS_HOME=${JENKINS_HOME:-/var/lib/jenkins} \
    JENKINS_UID=${JENKINS_UID:-1000} \
    JENKINS_GID=${JENKINS_GID:-1000}

RUN set -ex; \
    mkdir -p /usr/share/man/man1; \
    yum -y update; \
    yum -y --setopt=tsflags=nodocs install glibc glibc-common; \
    yum -y --setopt=tsflags=nodocs install rootfiles; \
    yum -y --setopt=tsflags=nodocs install bash-completion tar gzip bzip2 zip unzip which wget curl telnet tcpdump rsync lsof procps hostname findutils util-linux net-tools iproute bind-utils mailx less mc vim-minimal vim-enhanced; \
    yum -y --setopt=tsflags=nodocs install openssh openssh-clients openssh-server; \
    yum -y --setopt=tsflags=nodocs install git svn hg; \
    yum -y --setopt=tsflags=nodocs install openssl; \
    yum -y --setopt=tsflags=nodocs --enablerepo ol7_optional_latest,ol7_developer_EPEL install python3 python3-devel python3-pip; \
    yum -y --setopt=tsflags=nodocs --enablerepo ol7_optional_latest,ol7_developer_EPEL install java-1.8.0-openjdk maven; \
    rm -rf /var/cache/yum/*

RUN set ex; \
    pip3 install -U \
    ipython

RUN set -ex; \
    ln -fs /usr/share/zoneinfo/Europe/Moscow /etc/localtime

ENV LANG='ru_RU.UTF-8' LANGUAGE='ru_RU:ru' LC_ALL='ru_RU.UTF-8'
# ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

RUN set -ex; \
    groupadd -g ${JENKINS_GID} ${JENKINS_GROUP}; \
    useradd -d ${JENKINS_HOME} -u ${JENKINS_UID} -g ${JENKINS_GID} -m -s /bin/bash -c "Jenkins Slave Server" ${JENKINS_USER}

RUN set -ex; \
    sed -i /etc/ssh/sshd_config \
    -e 's/#PermitRootLogin.*/PermitRootLogin no/' \
    -e 's/#RSAAuthentication.*/RSAAuthentication yes/'  \
    -e 's/#PasswordAuthentication.*/PasswordAuthentication no/' \
    -e 's/#SyslogFacility.*/SyslogFacility AUTH/' \
    -e 's/#LogLevel.*/LogLevel INFO/'

RUN set -ex; \
    echo "PS1='\[\e[1;33m\][\u@\h \W]\$\[\e[0m\]'" > /etc/profile.d/bash-color.sh

COPY runSSHD.sh /usr/local/bin/runSSHD.sh

EXPOSE 22

ENTRYPOINT ["runSSHD.sh"]
