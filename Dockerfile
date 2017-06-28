# eJudge
# VERSION 1
# Author: ultmaster

FROM ubuntu:16.04
MAINTAINER ultmaster scottyugochang@hotmail.com
ENV DEBIAN_FRONTEND noninteractive

RUN add-apt-repository ppa:longsleep/golang-backports -y
RUN apt-get update
RUN apt-get -y install software-properties-common python-software-properties python python-dev python-pip \
    locales python3-software-properties python3 python3-dev python3-pip \
    gcc g++ git libtool python-pip libseccomp-dev cmake openjdk-8-jdk nginx redis-server \
    mono-devel php gfortran perl ruby-full gobjc gnustep gnustep-devel ghc scala lua5.3 sbcl nodejs nodejs-legacy \
    r-base rustc fp-compiler clang pypy mono-complete fsharp ocaml-nox golang-go wget sbcl

RUN wget https://swift.org/builds/swift-3.1.1-release/ubuntu1604/swift-3.1.1-RELEASE/swift-3.1.1-RELEASE-ubuntu16.04.tar.gz
RUN tar zxf swift-*.tar.gz && chmod -R ugo+r swift-3.1.1-RELEASE-ubuntu16.04
RUN cp -frp swift-3.1.1-RELEASE-ubuntu16.04/usr /
RUN rm swift-*.tar.gz && rm -rf swift-3.1.1-RELEASE-ubuntu16.04

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Copy main code
RUN mkdir -p /var/www/ejudge
COPY . /var/www/ejudge/
WORKDIR /var/www/ejudge

# Install judger
RUN useradd -r compiler
COPY judger/java_policy /etc/
RUN cd judger && chmod +x runtest.sh
RUN cd judger && ./runtest.sh; exit 0

# Install checker
RUN cd testlib && ./build.sh

RUN pip3 install -r requirements.txt
RUN mkdir -p /judge_server /judge_server/round /judge_server/data /judge_server/tmp
RUN chmod 600 token.txt

HEALTHCHECK --interval=30s --retries=3 CMD python3 healthcheck.py

EXPOSE 4999

RUN chmod +x run.sh
CMD ./run.sh
