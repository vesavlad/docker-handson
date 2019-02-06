FROM ubuntu:16.04

MAINTAINER Vlad Vesa <vlad.vesa89@gmail.com>

# Get the latest version from https://developer.android.com/studio/index.html
ENV SDK_VERSION="3859397"

ENV ANDROID_HOME "/sdk"
ENV PATH "$PATH:${ANDROID_HOME}/tools:{$ANDROID_HOME}/platform-tools"
ENV DEBIAN_FRONTEND noninteractive

# installing dependencies
RUN apt-get -qq update && \
    apt-get install -qqy --no-install-recommends \
      git \
      curl \
      html2text \
      openjdk-8-jdk \
      libc6-i386 \
      lib32stdc++6 \
      lib32gcc1 \
      lib32ncurses5 \
      lib32z1 \
      unzip \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN rm -f /etc/ssl/certs/java/cacerts; \
    /var/lib/dpkg/info/ca-certificates-java.postinst configure

# downloading sdk with specified version
RUN curl -s https://dl.google.com/android/repository/sdk-tools-linux-${SDK_VERSION}.zip > /sdk.zip && \
    unzip /sdk.zip -d $ANDROID_HOME && \
    rm -v /sdk.zip

RUN mkdir -p $ANDROID_HOME/licenses/ \
  && echo "8933bad161af4178b1185d1a37fbf41ea5269c55" > $ANDROID_HOME/licenses/android-sdk-license \
  && echo "84831b9409646a918e30573bab4c9c91346d8abd" > $ANDROID_HOME/licenses/android-sdk-preview-license

# install the provided packages inside the repo, this may vary based on android configuration need to run de build
ADD packages.txt $ANDROID_HOME
RUN mkdir -p /root/.android && \
  touch /root/.android/repositories.cfg && \
  ${ANDROID_HOME}/tools/bin/sdkmanager --update && \
  (while [ 1 ]; do sleep 5; echo y; done) | ${ANDROID_HOME}/tools/bin/sdkmanager --package_file=/sdk/packages.txt

# Export JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/

WORKDIR /project
