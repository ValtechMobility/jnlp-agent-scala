FROM jenkins/inbound-agent:alpine as jnlp

FROM jenkins/agent:latest-jdk11

ARG version
LABEL Description="This is a base image, which allows connecting Jenkins agents via JNLP protocols" Vendor="Jenkins project" Version="$version"

ARG user=jenkins

USER root

COPY --from=jnlp /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-agent

RUN chmod +x /usr/local/bin/jenkins-agent &&\
    ln -s /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-slave

RUN apt-get update && apt-get install -y --no-install-recommends \
                openssh-client \
                ca-certificates \
                apt-transport-https \
                software-properties-common \
                gnupg \
                curl \
	       && rm -rf /var/lib/apt/lists/*

RUN echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | tee /etc/apt/sources.list.d/sbt.list \
        && echo "deb https://repo.scala-sbt.org/scalasbt/debian /" | tee /etc/apt/sources.list.d/sbt_old.list \
        && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823

RUN apt-get update && apt-get install -y sbt && rm /var/lib/apt/lists/*

# Timezone needs to be set. Otherwise test fail (it is sad but what can you do...)
RUN ln -fs /usr/share/zoneinfo/Europe/Berlin /etc/localtime && dpkg-reconfigure -f noninteractive tzdata

USER ${user}

WORKDIR /home/jenkins

RUN mkdir /home/jenkins/.m2 && mkdir /home/jenkins/.ivy2 && mkdir /home/jenkins/.sbt

VOLUME ["/home/jenkins/.m2"]
VOLUME ["/home/jenkins/.ivy2"]
VOLUME ["/home/jenkins/.sbt"]

ENTRYPOINT ["/usr/local/bin/jenkins-agent"]





