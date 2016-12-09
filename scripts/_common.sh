#
# Common variables
#

APPNAME="dynette"

# Dynette revision
REVISION="7bdf77492c1f340903c3d720637287cc8d879a15"

# Package name for dependencies
DEPS_PKG_NAME="dynette-deps"

# Remote URL to fetch tarball
SOURCE_URL="https://github.com/YunoHost/dynette/archive/${REVISION}.tar.gz"

# Remote URL to fetch tarball checksum
SOURCE_SHA256="0828bc19afcfff95302c0f095ce3755db0b2e1bfa9cc749e7befb5d23a5a1469"

# App package root directory should be the parent folder
PKGDIR=$(cd ../; pwd)

#
# Common helpers
#

# Create a user
#
# usage: ynh_mysql_create_user user pwd [host]
# | arg: user - the user name to create
# | arg: pwd - the password to identify user by
ynh_psql_create_user() {
        sudo su -c "psql" postgres <<< \
        "CREATE USER ${1} WITH PASSWORD '${2}';"
}

# Create a database and grant optionnaly privilegies to a user
#
# usage: ynh_mysql_create_db db [user [pwd]]
# | arg: db - the database name to create
# | arg: user - the user to grant privilegies
# | arg: pwd - the password to identify user by
ynh_psql_create_db() {
    db=$1
    # grant all privilegies to user
    if [[ $# -gt 1 ]]; then
        ynh_psql_create_user ${2} "${3}"
        sudo su -c "createdb -O ${2} $db" postgres
    else
        sudo su -c "createdb $db" postgres
    fi

}

# Drop a database
#
# usage: ynh_mysql_drop_db db
# | arg: db - the database name to drop
ynh_psql_drop_db() {
    sudo su -c "dropdb ${1}" postgres
}

# Drop a user
#
# usage: ynh_mysql_drop_user user
# | arg: user - the user name to drop
ynh_psql_drop_user() {
    sudo su -c "dropuser ${1}" postgres
}


# Download and extract sources to the given directory
# usage: extract_sources DESTDIR [AS_USER]
extract_sources() {
  local DESTDIR=$1
  local AS_USER=${2:-admin}

  # retrieve and extract Roundcube tarball
  tarball="/tmp/${APPNAME}.tar.gz"
  rm -f "$tarball"
  wget -q -O "$tarball" "$SOURCE_URL" \
    || ynh_die "Unable to download tarball"
  echo "$SOURCE_SHA256 $tarball" | sha256sum -c >/dev/null \
    || ynh_die "Invalid checksum of downloaded tarball"
  exec_as "$AS_USER" tar xzf "$tarball" -C "$DESTDIR" --strip-components 1 \
    || ynh_die "Unable to extract tarball"
  rm -f "$tarball"

  # apply patches
  (cd "$DESTDIR" \
   && for p in ${PKGDIR}/patches/*.patch; do \
        exec_as "$AS_USER" patch -p1 < $p; done) \
    || ynh_die "Unable to apply patches"
}

# Execute a command as another user
# usage: exec_as USER COMMAND [ARG ...]
exec_as() {
  local USER=$1
  shift 1

  if [[ $USER = $(whoami) ]]; then
    eval "$@"
  else
    # use sudo twice to be root and be allowed to use another user
    sudo sudo -u "$USER" "$@"
  fi
}
