#!/bin/sh
#
# Install salt-minion-7 by  rpm   on  centos7

LOG_FILE="/var/log/salt-minion_install.log"
FILENAME="salt-minion-7.tar.gz"
SOFT_DIR_NAME="salt-minion-7"


base_softs=(systemd-python
            python-kitchen
            yum-utils
            libyaml)

pkgs=(
python-chardet-2.2.1-1.el7_1.noarch.rpm
libsodium-1.0.5-1.el7.x86_64.rpm
openpgm-5.2.122-2.el7.x86_64.rpm
python-babel-0.9.6-8.el7.noarch.rpm
python-crypto-2.6.1-1.el7.centos.x86_64.rpm
python-futures-3.0.3-1.el7.noarch.rpm
python-markupsafe-0.11-10.el7.x86_64.rpm
python-jinja2-2.7.2-2.el7.noarch.rpm
python-msgpack-0.4.6-1.el7.x86_64.rpm
python-tornado-4.2.1-1.el7.x86_64.rpm
PyYAML-3.11-1.el7.x86_64.rpm
python-urllib3-1.10.2-2.el7_1.noarch.rpm
python-requests-2.6.0-1.el7_1.noarch.rpm
zeromq-4.1.4-5.el7.x86_64.rpm
python-zmq-15.3.0-2.el7.x86_64.rpm
salt-2016.3.3-2.el7.noarch.rpm
salt-minion-2016.3.3-2.el7.noarch.rpm
)

err(){
  local msg
  msg="[`/bin/date +"%F %T"`] : $*"
  echo $msg :  >> ${LOG_FILE}
  exit -1
}

user(){
  if [ $(id -u) !=  0 ]
  then
    local msg
    msg="ERROR,Install User is not root."
    err $msg
  fi
}

dir(){
  if [ ! -f `pwd`/$FILENAME ]
  then
    local msg
    msg="$FILENAME isn't exists."
    err $msg
  fi
}

unpack(){
  local msg
  tar xf $FILENAME >/dev/null 2>&1
  if [ $? != 0 ]
  then
    msg="ERROR,unpack $FILENAME."
    err $msg
  fi
}

base_install(){
  local soft
  local msg
  for soft in ${base_softs[@]}
  do
    yum install $soft -y >>/dev/null 2>&1
    if [ $? != 0 ]
    then
      msg="ERROR,Install $soft."
      err $msg
    fi
  done
}

rpm_install(){
  local pkg
  local soft
  local msg1
  local msg2
  cd `pwd`/${SOFT_DIR_NAME}
  if [ $? != 0 ]
  then
    msg1="ERROR,change ${SOFT_DIR_NAME}."
    err $msg1
  fi

  for pkg in ${pkgs[@]}
  do
    soft=`echo  $pkg| awk -F ".rpm" '{print $1}'`
    /usr/bin/rpm -q  $soft >>/dev/null 2>&1
    if [ $? != 0 ]
    then
      yum install -y $pkg >> /dev/null 2>&1
      if [ $? != 0 ]
      then
        msg2="ERROR,Install ${pkg}."
        err $msg2
      fi
    fi
  done
}

auto_start(){
  local msg
  systemctl  enable salt-minion.service >>/dev/null 2>&1
  if [ $? != 0 ]
  then
    msg="ERROR,auto start salt-minion.service."
    err $msg
  fi
}


user
dir
unpack
base_install
rpm_install

