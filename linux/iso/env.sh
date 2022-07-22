#!/bin/bash
#Author: written by hbzhao
#Function: As header of passing parameters to a script.
set -e
#clear
DIR_CURR=$(cd $(dirname "$0"); pwd)
cd ${DIR_CURR}
usage(){ echo -e "Usages:\n\t$0 -a <apps> -p <port> [-t] [--set-value]"; }
[[ -z "$1" ]] && { usage; exit 1; }
while [ -n "$1" ]; do
    case "$1" in
    -a | --allow ) shift; [ -z $1 ] && { usage; exit 1; }; ALLOW=$1;;
    -h | --help  ) usage; exit 1;;
    -p | --ports ) shift; [ -z $1 ] && { usage; exit 1; }; PORTS=$1;;
    -t | --types ) TYPES=true;;
    --set-value  ) VALUE=true;;
    *) usage; exit 1;;
    esac
    shift
done
[ x${ALLOW} = x ] && ALLOW=test ; echo ALLOW=${ALLOW}
[ x${PORTS} = x ] && PORTS=5911 ; echo PORTS=${PORTS}
[ x${TYPES} = x ] && TYPES=true ; echo TYPES=${TYPES}
[ x${VALUE} = x ] && VALUE=false; echo VALUE=${VALUE}
