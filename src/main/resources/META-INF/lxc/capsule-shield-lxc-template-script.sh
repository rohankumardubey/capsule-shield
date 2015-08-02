#!/bin/bash

#
# Copyright (c) 2015, Parallel Universe Software Co. and Contributors. All rights reserved.
#
# This program and the accompanying materials are licensed under the terms
# of the Eclipse Public License v1.0, available at
# http://www.eclipse.org/legal/epl-v10.html
#

# Client script for LXC container capsuleos image.
#
# @author circlespainter

## Failfast
set -eu

## Vars to be populated from options
FILE=
LXC_ROOTFS=

## Define path
export PATH=$PATH:/usr/sbin:/usr/bin:/sbin:/bin

cleanup() {
    return 0
}

usage() {
    cat <<EOF
LXC container creature for capsuleos.

Mandatory arguments:
[ --file <path> ]: The rootfs archive to be used

LXC internal arguments (do not pass manually!):
[ --name <name> ]: The container name
[ --path <path> ]: The path to the container
[ --rootfs <rootfs> ]: The path to the container's rootfs
[ --mapped-uid <map> ]: A uid map (user namespaces)
[ --mapped-gid <map> ]: A gid map (user namespaces)
EOF
    return 0
}

# Get inputs

options=$(getopt -o h -l file:,name:,path:,rootfs:,mapped-uid:,mapped-gid: -- "$@")

if [ $? -ne 0 ]; then
    usage
    exit 1
fi
eval set -- "${options}"

while :; do
    case "$1" in
        -h|--help)          usage && exit 1;;
        --file)             FILE=$2; shift 2;;
        --name)             shift 2;;
        --path)             shift 2;;
        --rootfs)           LXC_ROOTFS=$2; shift 2;;
        --mapped-uid)       shift 2;;
        --mapped-gid)       shift 2;;
        *)                  break;;
    esac
done

options=$(getopt -l name:,mapped-uid:,mapped-gid:,file:,rootfs: -- "$@")

# Check inputs

if [ $? -ne 0 ]; then
    usage
    exit 1
fi
eval set -- "${options}"

## Check for required binaries
for bin in tar; do
    if ! type $bin >/dev/null 2>&1; then
        echo "ERROR: Missing required tool: $bin" 1>&2
        exit 1
    fi
done

## Check that we have all variables we need
if [ -z "$LXC_ROOTFS" ]; then
    echo "ERROR: Not running through LXC." 1>&2
    exit 1
fi
if [ -z "$FILE" ]; then
    echo "ERROR: The --file option is mandatory." 1>&2
    exit 1
fi

# Trap all exit signals
trap cleanup EXIT HUP INT TERM

# Unpack the rootfs
tar --numeric-owner -xzf ${FILE} -C ${LXC_ROOTFS}

exit 0
