#!/bin/bash

#=================================================
# COMMON VARIABLES AND CUSTOM HELPERS
#=================================================


dynette_regen_named_conf_path="/etc/systemd/system/$app-regen-named-conf.path"

_git_clone_or_pull() {
    repo_dir="$1"
    repo_url="${2:-}"

    if [[ -z "$repo_url" ]]; then
        repo_url=$(ynh_read_manifest "upstream.code")
    fi

    if [ -d "$repo_dir" ]; then
        ynh_exec_as_app git -C "$repo_dir" fetch --quiet
    else
        ynh_exec_as_app git clone "$repo_url" "$repo_dir" --quiet
    fi
    ynh_exec_as_app git -C "$repo_dir" pull --quiet
}

_update_venv() {
    if [ ! -d "venv" ]; then
        ynh_exec_as_app python3 -m venv venv
    fi
    ynh_exec_as_app venv/bin/pip install --upgrade pip >/dev/null
}


_add_config_named() {
    mv "/etc/bind/named.conf.options" "/etc/bind/named.conf.options.orig"
    ynh_config_add --template="named.conf.options" --destination="/etc/bind/named.conf.options"
    chown root:bind "/etc/bind/named.conf.options"
    chmod g+r "/etc/bind/named.conf.options"
}

_rm_config_named() {
    ynh_safe_rm "/etc/bind/named.conf.options"
    mv "/etc/bind/named.conf.options.orig" "/etc/bind/named.conf.options"
}
