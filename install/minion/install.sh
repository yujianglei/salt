#!/bin/sh
#
# Install salt-minion-7 or salt-minion-6
# by  rpm   on  centos7 or centos6.

LOG_FILE="/var/log/salt-minion_install.log"
salt_master_ip='10.10.21.80'
FILENAME=""
SOFT_DIR_NAME=""
base_softs=()
salt_softs=()

version(){
  local kernel_version
  kernel_version=`uname -r`
  major_ver=`echo ${kernel_version}| \
             awk -F "-" '{print $1}'| \
             awk -F "." '{print $1}'`
  echo ${major_ver}
}

def_var(){
  local v
  v=$(version)
  if [ $v -eq 3 ]
  then
    FILENAME="salt-minion-7.tar.gz"
  else
    FILENAME="salt-minion-6.tar.gz"
  fi

  if [ ! -z "$FILENAME" -a "$FILENAME" != " " ]
  then
    SOFT_DIR_NAME=`echo $FILENAME |
                   cut -d '.' -f1`
  fi
}


def_base_soft(){
  local v
  v=$(version)
  if [ $v -eq 3 ]
  then
    base_softs=(systemd-python
                python-kitchen
                yum-utils
                libyaml)
  else
    base_softs=(libxml2-python
               libyaml
               pciutils
               python-babel
               python-backports
               python-backports-ssl_match_hostname
               python-chardet
               python-requests
               python-six
               python-urllib3
               yum-utils
    )
  fi
  echo ${base_softs[@]}
}

def_salt_soft(){
  local v
  v=$(version)
  if [ $v -eq 3 ]
  then
    salt_softs=(
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
  else
    salt_softs=(
          python-crypto-2.6.1-2.el6.x86_64.rpm
          python-futures-3.0.3-1.el6.noarch.rpm
          python-markupsafe-0.11-10.el6.x86_64.rpm
          python-jinja2-2.7.3-1.el6.noarch.rpm
          python-msgpack-0.4.6-1.el6.x86_64.rpm
          python-tornado-4.2.1-1.el6.x86_64.rpm
          PyYAML-3.11-1.el6.x86_64.rpm
          zeromq-4.0.5-4.el6.x86_64.rpm
          salt-minion-2016.3.3-1.el6.noarch.rpm
    )
  fi
  echo ${salt_softs[@]}
}





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
  dir()
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
  local res
  local msg

  res=$(def_base_soft)
  for soft in ${res[@]}
  do
    rpm -q $soft  >>/dev/null 2>&1
    if [ $? != 0 ]
    then
        yum install $soft -y >>/dev/null 2>&1
        if [ $? != 0 ]
            then
                msg="ERROR,Install $soft."
                err $msg
        fi
    else
      yum  update $soft -y >>/dev/null 2>&1
    fi
  done
}

salt_install(){

  local pkg
  local res
  local soft
  local msg1
  local msg2
  cd `pwd`/${SOFT_DIR_NAME}
  if [ $? != 0 ]
  then
    msg1="ERROR,change ${SOFT_DIR_NAME}."
    err $msg1
  fi

   res=$(def_salt_soft)
  for pkg in ${res[@]}
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

config(){
  local id_desc
  id_desc=`hostname`
  echo "master: ${salt_master_ip}" >>/etc/salt/minion && \
  echo "id: ${id_desc}" >>/etc/salt/minion
  if [ $? != 0 ]
  then
    msg="ERROR,Configure salt-minion."
    err $msg
  fi
}


auto_start(){
  local v
  local msg
  v=$(version)
  if [ $v -eq 3 ]
  then
    systemctl  enable salt-minion.service >>/dev/null 2>&1 && \
    systemctl  start  salt-minion.service
  else
    chkconfig  --add  salt-minion >>/dev/null 2>&1 && \
    service salt-minion  start
  fi

  if [ $? != 0 ]
  then
    msg="ERROR,auto start  or start salt-minion.service."
    err $msg
  fi
}


main(){
  user
  def_var
  unpack
  base_install
  salt_install
  config
  auto_start
}


main
