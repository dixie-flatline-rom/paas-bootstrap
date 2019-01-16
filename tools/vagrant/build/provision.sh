#!/bin/bash
# Assumed that this script is run with sudo permissions by vagrant provisioner

locale-gen en_GB.UTF-8

BOSH_RELEASE=https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-5.1.2-linux-amd64

TERRAFORM_VERSION=0.11.8
TERRAFORM_RELEASE=terraform_${TERRAFORM_VERSION}_linux_amd64.zip
TERRAFORM_URL=https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/${TERRAFORM_RELEASE}

CREDHUB_VERSION=2.0.0
CREDHUB_RELEASE=credhub-linux-${CREDHUB_VERSION}.tgz
CREDHUB_URL=https://github.com/cloudfoundry-incubator/credhub-cli/releases/download/${CREDHUB_VERSION}/${CREDHUB_RELEASE}

FLY_VERSION=4.1.0
FLY_RELEASE=fly_linux_amd64
FLY_URL=https://github.com/concourse/concourse/releases/download/v${FLY_VERSION}/${FLY_RELEASE}

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Some useful shorthand
VCMD="--version"


echo ""
echo "== Provisioning tools =="
echo ""

installing() {
  printf "${NC}> %-20s -> " "$1"
}

version() {
  $1 $2 | head -n 1
}

fail() {
  printf "${RED}failed to install !!\n"
}

# ainstall(apt-name,cmd [,versioncmd]) - install with apt
ainstall() {
  # Allow specifying of command line arg for version other than the default
  local CMD=${VCMD}
  if [ ! -z "$3" ]; then CMD="$3"; fi

  installing $1
  if apt -y install $1 &>/dev/null; then
    printf "${GREEN}$(version $2 $CMD)\\n"
  else
    fail
  fi
}

# sinstall(snap-name,cmd) - install with snap
sinstall() {
  printf "${NC}> %-20s -> " "$1"
  if snap install $1 &>/dev/null; then
    printf "${GREEN}%s\\n" "$($2 --version)"
  else
    printf "${RED}failed to install !!\n"
  fi
}

# cinstall(binary,url) - install with curl
cinstall() {
  installing $1
  if curl -s -Lo $1 $2 && chmod +x $1 && mv -f $1 /usr/local/bin/$1 &>/dev/null; then
    printf "${GREEN}$(${1} ${VCMD} | head -n 1)\n"
  else
    fail
  fi
}

# winstall(binary,url,archive,type) - install with wget (where type=tar|zip|none)
winstall() {
  CMD=":" # default noop
  if [ ${4} = "zip" ]; then CMD="unzip -qo ${3}"; fi
  if [ ${4} = "tar" ]; then CMD="tar zxf ${3}"; fi

  installing $1
  if wget -q ${2} && ${CMD} && chmod +x ${1} && mv -f ${1} /usr/local/bin/${1} ; then
    rm ${3}
    printf "${GREEN}$(version ${1} ${VCMD})\n"
  else
    fail
  fi
}

echo "Installing prereqs ..."
{
  # yq
  add-apt-repository -y ppa:rmescandon/yq

  # cf cli
  wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | sudo apt-key add -
  echo "deb https://packages.cloudfoundry.org/debian stable main" | sudo tee /etc/apt/sources.list.d/cloudfoundry-cli.list
  apt-get update
  apt-get install -y unzip python-pip

  # prereqs for bosh to install ruby
  apt-get -y --no-install-recommends install build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev libgdbm-dev ncurses-dev automake libtool bison subversion pkg-config libffi-dev

} &>/dev/null # throw away output

echo "Installing tools ..."
ainstall cf-cli cf                                            # cf cli
ainstall mysql-client  mysql                                  # mysql
ainstall postgresql-client psql                               # postgres
ainstall jq jq                                                # jq
#ainstall yq yq                                                # yq
sinstall yq yq
cinstall bosh ${BOSH_RELEASE}                                 # bosh
winstall terraform ${TERRAFORM_URL} ${TERRAFORM_RELEASE} zip  # terraform
winstall credhub ${CREDHUB_URL} ${CREDHUB_RELEASE} tar        # credhub
cinstall fly ${FLY_URL}                                       # fly

# echo "Installing supporting tools ..."
ainstall silversearcher-ag ag                                 # ag
ainstall golang-go go version                                 # go

