#!/bin/bash

root_dir=$(pwd)
exec_name="demo"

workflow=
array_info=

function usage () {
  space_symbol=" "
  printf "Usage:\n"
  printf "sh ./demo_run_new.sh [-e exec] [-a array] [-f workflow] [-h] [-c]\n"
  printf "%-10s%-10s%s\n" "${space_symbol}" "-a" "some array message, such like \"test1,test2\", use \",\" to split"
  printf "%-10s%-10s%s\n" "${space_symbol}" "-e" "exec's name. if not set, will use the default name \"exec\""
  printf "%-10s%-10s%s\n" "${space_symbol}" "-f" "workflow test's cfg information. If not set, workflow test will not be processing"
  printf "%-10s%-10s%s\n" "${space_symbol}" "-h" "show this script's usage"
  printf "%-10s%-10s%s\n" "${space_symbol}" "-c" "be careful!!! this option will clear all the temporary files"
}

function log () {
  TIME=$(date "+%Y-%m-%d %H:%M:%S")

  if [[ "Info" == "$1" ]]; then 
    printf "\033[0;32m" 
  elif [[ "Debug" == "$1" ]]; then
    printf "\033[0;35m"
  elif [[ "Warn" == "$1" ]]; then
    printf "\033[0;33m"
  elif [[ "Error" == "$1" ]]; then
    printf "\033[5;41;37m"
  fi
  printf "%s [%-5s]   %s\033[0m\n" "${TIME}" "$1" "$2"
}

function clean () {
    log Warn "this operation will clean all the temporary files"
    read -r -p "Are You Sure To Begin Cleanning? [Y/n] " input
    case $input in
        [yY][eE][sS]|[yY])
            log Warn "Begin To Cleanning...\n"
            # rm .tmp -rvf
            exit 0;
            ;;

        [nN][oO]|[nN])
            log Warn "Do Nothing! Will Exit Safely..."
            exit 0;
            ;;
            
        *)
            log Error "Invalid input..."
            exit -1
            ;;
    esac
}

function parseArgs () {
  while getopts "a:e:f:hc" opts; do
    case $opts in
      e)
        exec_name=$OPTARG
        ;;
      a)
        array_str=$OPTARG
        echo $array_str
        array_info=(${array_str//,/ })
        ;;
      f)
        workflow=$OPTARG
        ;;
      h)
        usage
        exit 0
        ;;
      c)
        clean
        exit 0
        ;;
      \?)
        log Error "Invalid option: -$OPTARG"
        usage
        exit 1
        ;;
      :)
        log Error "Option [-$OPTARG] requires an argument"
        usage
        exit 1
        ;;
    esac
  done
  if [[ -z $array_info ]]; then
    log Error "no array info!"
    usage
    exit 1
  fi
}

parseArgs "$@"
log Info "root dir: ${root_dir}"
log Debug "exec_name: ${exec_name}"
log Warn "workflow: ${workflow}"
log Error "array_info: ${array_info[*]}"