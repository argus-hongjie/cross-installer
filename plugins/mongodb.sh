install_mongodb() {
  hascmd apt-get && { install_mongodb_apt; return ;}
  hascmd yum && { install_mongodb_yum; return ;}
  os_version
  exit 1
}

install_mongodb_apt() {
  hascmd apt-key && apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
  test -f /etc/lsb-release && . /etc/lsb-release
  if test "$DISTRIB_ID" = Ubuntu; then
    echo "deb http://repo.mongodb.org/apt/ubuntu $DISTRIB_CODENAME/mongodb-org/3.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.0.list
  else
    echo "deb http://repo.mongodb.org/apt/debian wheezy/mongodb-org/3.0 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.0.list
  fi
  apt-get install -y mongodb-org
}

install_mongodb_yum() {
  cat >/etc/yum.repos.d/mongodb-org-3.0.repo <<EOF
[mongodb-org-3.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.0/x86_64/
gpgcheck=0
enabled=1
EOF
  yum install -y mongodb-org
}
