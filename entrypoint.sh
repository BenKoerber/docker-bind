#!/bin/sh

set -e

set_environment_variable_defaults() {
  # Source of the initial bind configuration (/etc/bind). Values
  ## - alpine:  use files shipped with alpine 
  ## - image:   use files shipped with image (image/etc/bind)
  ## - custom:  use files of directory ${BIND_CUSTOM_CONFIG_DIR}
  BIND_INITIAL_CONFIG=${BIND_INITIAL_CONFIG:-image} 
  # Source directories of custom configuration files  
  BIND_CUSTOM_CONFIG_DIR=${BIND_CUSTOM_CONFIG_DIR:-/config/custom} 
}

create_bind_dirs() {
  mkdir -p ${BIND_CONFIG_DIR}

  # populate default bind configuration directory if it does not exist and link it
  if [ ! -d ${BIND_CONFIG_DIR}/etc/bind ]; then
    mkdir -p ${BIND_CONFIG_DIR}/etc
    case ${BIND_INITIAL_CONFIG} in
      alpine)
        mv /etc/bind ${BIND_CONFIG_DIR}/etc
        ;;
      image)
        cp -r /config/image/etc/bind ${BIND_CONFIG_DIR}/etc/
        ;;
      custom)
        cp -r ${BIND_CUSTOM_CONFIG_DIR} ${BIND_CONFIG_DIR}/etc/
        ;;
    esac
  fi
  rm -rf /etc/bind
  ln -sf ${BIND_CONFIG_DIR}/etc/bind /etc/bind

  # link default bind lib directory
  if [ ! -d ${BIND_CONFIG_DIR}/var/lib/bind ]; then
    mkdir -p ${BIND_CONFIG_DIR}/var/lib/bind
  fi
  rm -rf /var/lib/bind
  ln -sf ${BIND_CONFIG_DIR}/var/lib/bind /var/lib/bind

  # set permissions and ownership
  chmod -R 0775 ${BIND_CONFIG_DIR}
  chown -R ${BIND_USER}:${BIND_USER} ${BIND_CONFIG_DIR}  

}

create_pid_dir() {
  mkdir -m 0775 -p /var/run/named
  chown root:${BIND_USER} /var/run/named
}

create_bind_cache_dir() {
  mkdir -m 0775 -p /var/cache/bind
  chown root:${BIND_USER} /var/cache/bind
}

# create bind dirs
set_environment_variable_defaults
create_bind_dirs
create_pid_dir
create_bind_cache_dir


# allow arguments to be passed to named
if [[ ${1} == named || ${1} == $(which named) ]]; then
  DEFAULT_START="1"
  shift
else
  DEFAULT_START="0"
fi

# default behaviour is to launch named
if [ $DEFAULT_START -eq "1" ]; then
  echo "Starting container with named using command: $(which named) -u ${BIND_USER} -g $@"
  exec $(which named) -u ${BIND_USER} -g $@
else
  echo "Starting container using command: $@"
  exec "$@"
fi



