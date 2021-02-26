#!/bin/bash

set -e
# A POSIX variable
OPTIND=1

function show_help () {
    echo "Optional flags:"
    echo "                -v = verbose. Default is 0/Off"
    echo "Mandatory flags:"
    echo "                -e = envirement to use, for example dev, qa or prod"
    echo "                -o = Terraform Operation."
    echo "Example useage:"
    echo "               $./all_module.sh -e dev -o apply"
}

function deploy () {
    echo "*--- Start deploying $1 ---*"
    echo "--- Init stage of $1 ---"
    env=dev make -f $1/Makefile init
    echo "--- Plan stage of $1 ---"
    env=dev make -f $1/Makefile plan
    echo "--- Apply stage of $1 ---"
    env=dev make -f $1/Makefile apply
    echo "*--- End of $1 deployment ---*"
}

echo "Start"

# Initialize our own variables:
ENV=""
ENVOPT=""
VERBOSE=0
TFMODULES="network security process"

while getopts "h?ve:o:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    v)  VERBOSE=1
        ;;
    e)  ENV=$OPTARG
        ;;
    o)  ENVOPT=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))
[ "${1:-}" = "--" ] && shift

if [ $VERBOSE -eq 1 ]; then echo "verbose=$VERBOSE, env='$ENV', env_opt='$ENVOPT' Leftovers: $@"; fi


if [ $ENVOPT = "deploy" ]; then
    echo "deploy"
    for module in $TFMODULES; do
        deploy $module
    done
fi