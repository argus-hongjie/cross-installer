# See https://github.com/frol/docker-alpine-oraclejdk8/blob/cleaned/Dockerfile
add_jdk_8_nodesktop() {
  export JAVA_VERSION=${JAVA_VERSION:-8} \
    JAVA_UPDATE=${JAVA_UPDATE:-92} \
    JAVA_BUILD=${JAVA_BUILD:-14} \
    JAVA_HOME="${JAVA_HOME:-/usr/lib/jvm/default-jvm}"

    cd "/tmp" && \
    curl -fsSLO --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
        "http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION}u${JAVA_UPDATE}-b${JAVA_BUILD}/jdk-${JAVA_VERSION}u${JAVA_UPDATE}-linux-x64.tar.gz" && \
    tar -xzf "jdk-${JAVA_VERSION}u${JAVA_UPDATE}-linux-x64.tar.gz" && \
    mkdir -p "/usr/lib/jvm" && \
    mv "/tmp/jdk1.${JAVA_VERSION}.0_${JAVA_UPDATE}" "/usr/lib/jvm/java-${JAVA_VERSION}-oracle" && \
    ln -s "java-${JAVA_VERSION}-oracle" "$JAVA_HOME" && \
    ln -s "$JAVA_HOME/bin/"* "/usr/bin/" && \
    echo "export JAVA_HOME=$JAVA_HOME" > /etc/profile.d/java.sh || return

    rm -rf "$JAVA_HOME/"*src.zip && \
    rm -rf "$JAVA_HOME/lib/missioncontrol" \
           "$JAVA_HOME/lib/visualvm" \
           "$JAVA_HOME/lib/"*javafx* \
           "$JAVA_HOME/jre/lib/plugin.jar" \
           "$JAVA_HOME/jre/lib/ext/jfxrt.jar" \
           "$JAVA_HOME/jre/bin/javaws" \
           "$JAVA_HOME/jre/lib/javaws.jar" \
           "$JAVA_HOME/jre/lib/desktop" \
           "$JAVA_HOME/jre/plugin" \
           "$JAVA_HOME/jre/lib/"deploy* \
           "$JAVA_HOME/jre/lib/"*javafx* \
           "$JAVA_HOME/jre/lib/"*jfx* \
           "$JAVA_HOME/jre/lib/amd64/libdecora_sse.so" \
           "$JAVA_HOME/jre/lib/amd64/"libprism_*.so \
           "$JAVA_HOME/jre/lib/amd64/libfxplugins.so" \
           "$JAVA_HOME/jre/lib/amd64/libglass.so" \
           "$JAVA_HOME/jre/lib/amd64/libgstreamer-lite.so" \
           "$JAVA_HOME/jre/lib/amd64/"libjavafx*.so \
           "$JAVA_HOME/jre/lib/amd64/"libjfx*.so && \
    rm /tmp/*
}

add_jdk_6_apt() {
  local remove_spc=''
  hascmd add-apt-repository || {
    remove_spc=1
    main add-pkg software-properties-common || return
  }
  echo 'oracle-java6-installer shared/accepted-oracle-license-v1-1 select true' | \
  debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  main add-pkg oracle-java6-installer && \
  rm -rf /var/cache/oracle-jdk6-installer || return

  test "$remove_spc" && { main remove-pkg software-properties-common || return ;}

  export JAVA_HOME=/usr/lib/jvm/java-6-oracle && \
  echo "export JAVA_HOME=$JAVA_HOME" >> /etc/profile.d/java.sh
}
