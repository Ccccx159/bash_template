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

function fn_Clean () {
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

function fn_ParseArgs () {
  while getopts "a:e:f:hc" opts; do
    case $opts in
      e)
        exec_name=$OPTARG
        ;;
      a)
        array_str=$OPTARG
        # echo $array_str
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
        fn_Clean
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

# 获取特定路径下，指定后缀的文件路径
function fn_GetFileList() {
  local suffix=$1
  local dir=$2
  local fileList=$(ls ${dir}/*.${suffix})
  echo ${fileList}

  return $?
}

# 查找指定文件是否存在 file 支持正则表达式
function fn_QueryFileIsExist () {
  local file=$1
  local dir=$2
  local fileNum=$(ls ${dir}/${file} 2> /dev/null | wc -l)
  if [[ "0" == "${fileNum}" ]]; then
    log Error "${dir}/${file} : No such file or directory"
  else
    log Info "${dir}/${file} exist"
    for file_opt in $(ls ${dir}/${file})
    do
      log Debug "${file_opt}"
    done
  fi
  return ${fileNum}
}

# #： 表示从左边算起第一个
# %： 表示从右边算起第一个
# ##：表示从左边算起最后一个
# %%：表示从右边算起最后一个
# *： 表示要删除的内容

# 也可以使用 basename, echo $(basename ${file})
# 已知后缀时，basename可以直接去除后缀 echo $(basename ${file} ${suffix})
# 截取文件名
function fn_GetFileName () {
  local file=$1
  local name=${file##*/}
  echo ${name}
  return $?
}

# 截取不带后缀的文件名
function fn_GetFileNameWithoutSuffix () {
  local file=$1
  local fullname=${file##*/}
  local name=${fullname%%.*}
  echo ${name}
  return $?
}

# 截取文件路径
function fn_GetFilePath () {
  local file=$1
  local path=${file%/*}
  echo ${path}
  return $?
}

function fn_GetFileSuffix () {
  local file=$1
  local fileName=$(fn_GetFileName ${file})
  local suffix=${fileName#*.}
  echo ${suffix}
  return $?
}

fn_ParseArgs "$@"
log Info "root dir: ${root_dir}"
log Debug "exec_name: ${exec_name}"
log Warn "workflow: ${workflow}"
log Error "array_info: ${array_info[*]}"

echo ""
log Warn "function fn_GetFileList test begin..."
files=$(fn_GetFileList "jpg" "${root_dir}/.tmp/GetFileList/")
for file_opt in ${files[*]}
do
  log Debug "${file_opt}"
done
log Warn "function fn_GetFileList test finish..."

echo ""
log Warn "function fn_QueryFileIsExist test begin..."
fn_QueryFileIsExist "*.sh" "."
if [[ 0 -ne $? ]]; then
  log Info "Query Successfully"
else
  log Warn "Query finished, but No such file or directory...Please check, if it's necessary"
fi
log Warn "function fn_QueryFileIsExist test finish..."

echo ""
log Warn "function fn_GetFilexxx test begin..."
filePath="$(pwd)/$0"
log Debug "file [${filePath}]"
log Debug "GetFileName: $(fn_GetFileName ${filePath})"
log Debug "GetFileNameWithoutSuffix: $(fn_GetFileNameWithoutSuffix ${filePath})"
log Debug "GetFilePath: $(fn_GetFilePath ${filePath})"
log Debug "GetFileSuffix: $(fn_GetFileSuffix ${filePath})"
log Warn "function fn_GetFilexxx test finish..."