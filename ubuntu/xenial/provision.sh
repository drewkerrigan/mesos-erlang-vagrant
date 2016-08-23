export DEBIAN_FRONTEND=noninteractive
export HOME=/home/ubuntu

# Common
mkdir -p $HOME/bin
export PATH="$PATH:$HOME/bin"

# Install mesos, marathon, zk, docker
apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
CODENAME=$(lsb_release -cs)
echo "deb http://repos.mesosphere.io/${DISTRO} ${CODENAME} main" |  sudo tee /etc/apt/sources.list.d/mesosphere.list
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
echo "deb https://get.docker.io/ubuntu docker main" | sudo tee /etc/apt/sources.list.d/docker.list
apt-get -y update > /dev/null
apt-get -y upgrade > /dev/null
apt-get -y install software-properties-common
add-apt-repository -y ppa:openjdk-r/ppa
apt-get -y update > /dev/null
apt-get -y install make git gcc g++ curl
apt-get -y install python-dev libcppunit-dev libunwind8-dev autoconf autotools-dev libltdl-dev libtool autopoint libcurl4-openssl-dev libsasl2-dev
apt-get -y install openjdk-8-jdk default-jre python-setuptools python-protobuf
update-java-alternatives -s /usr/lib/jvm/java-1.8.0-openjdk-amd64
apt-get -y install libprotobuf-dev protobuf-compiler
#apt-get -y install marathon
#apt-get -y install mesos=0.26.0-0.2.145.ubuntu1404
#apt-get -y install mesos=0.28.2-2.0.27.ubuntu1404
apt-get -y install mesos
apt-mark hold mesos
apt-get -y install lxc-docker
apt-get -y install resolvconf

# Configure mesos
echo "1" > /etc/mesos-master/quorum
echo "/var/lib/mesos" > /etc/mesos-master/work_dir

# Mesos DNS
cd $HOME/bin
wget https://github.com/mesosphere/mesos-dns/releases/download/v0.5.2/mesos-dns-v0.5.2-linux-amd64
chmod 755 mesos-dns-v0.5.2-linux-amd64
ln -fs mesos-dns-v0.5.2-linux-amd64 mesos-dns
# Configure Resolvconf
echo "nameserver 10.0.2.15" > /etc/resolvconf/resolv.conf.d/head
resolvconf -u

service zookeeper restart
service mesos-slave restart
service mesos-master restart

# Python
apt-get install make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils liblzma-dev
apt-get -y install git zip python-pip
pip install jsonschema
pip install virtualenv
pip install tox

curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash
[ $(grep -c '#pyenv' "$HOME/.bashrc") -eq 0 ] && (
    echo '#pyenv' >> $HOME/.bashrc
    echo 'export PATH="/home/ubuntu/.pyenv/bin:$PATH"' >> $HOME/.bashrc
    echo 'eval "$(pyenv init -)"' >> $HOME/.bashrc
    echo 'eval "$(pyenv virtualenv-init -)"' >> $HOME/.bashrc
)
export PATH="/home/ubuntu/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
pyenv update
pyenv install 3.4.5
pyenv virtualenv 3.4.5 dcos
# pyenv activate dcos


# Golang
bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
[ $(grep -c '#gvm' "$HOME/.bashrc") -eq 0 ] && (
    echo '#gvm' >> $HOME/.bashrc
    echo "source $HOME/.gvm/scripts/gvm" >> $HOME/.bashrc
    echo "gvm use go1.6"
)
source $HOME/.gvm/scripts/gvm
gvm install go1.4 -B
gvm use go1.4
export GOROOT_BOOTSTRAP=$GOROOT
gvm install go1.6
gvm use go1.6

# Kerl / Erlang
apt-get -y install libncurses5-dev libpam0g-dev
apt-get install -y build-essential autoconf libncurses5-dev openssl libssl-dev fop xsltproc unixodbc-dev libpam0g-dev maven
KERL_VSN="1.1.1"
KERL_DIR="$HOME/bin/kerl-$KERL_VSN"
TARGET_ERL="19.0"
[ ! -d "kerl-$KERL_VSN" ] && (
   curl -L -O https://github.com/kerl/kerl/archive/$KERL_VSN.tar.gz
   tar zxf $KERL_VSN.tar.gz && rm $KERL_VSN.tar.gz
   [ -f "$KERL_DIR/kerl" ] && ln -nsf "$KERL_DIR/kerl" "$HOME/bin/kerl"
   )
[ $(which kerl) ] && (
    kerl update releases
    [ $(kerl list builds | grep -c "$TARGET_ERL") -eq 0 ] && kerl build "$TARGET_ERL" "$TARGET_ERL"
    [ $(kerl list installations | grep -c "$TARGET_ERL") -eq 0 ] && kerl install "$TARGET_ERL" "$HOME/erlang/$TARGET_ERL"
    ) || echo "ERROR: kerl was not installed"
[ $(grep -c '#kerl_completion' "$HOME/.bashrc") -eq 0 ] && (
    echo '#kerl_completion' >> "$HOME/.bashrc"
    echo "[ -f \"$KERL_DIR/bash_completion/kerl\" ] && . \"$KERL_DIR/bash_completion/kerl\"" >> $HOME/.bashrc
)
[ $(grep -c '#Erlang_activate' "$HOME/.bashrc") -eq 0 ] && (
    echo "#Erlang_activate" >> "$HOME/.bashrc"
    echo ". \$HOME/erlang/$TARGET_ERL/activate" >> "$HOME/.bashrc"
    echo 'export PATH=$PATH:$HOME/bin' >> "$HOME/.bashrc"
)
[ -f "$HOME/erlang/$TARGET_ERL/activate" ] && . "$HOME/erlang/$TARGET_ERL/activate"

# Fix permissions
chown -R ubuntu:ubuntu $HOME

# Marathon
cd $HOME/bin
curl -O http://downloads.mesosphere.com/marathon/v1.1.1/marathon-1.1.1.tgz
tar xzf marathon-1.1.1.tgz
#service marathon restart

# Launch Mesos DNS
# curl -v -XPUT -H 'Content-Type: application/json' http://localhost:8080/v2/apps -d @/vagrant/vagrant/mesos-dns-marathon.json
