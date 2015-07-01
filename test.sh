#!/bin/bash
DIR=$1
DISTRIB=$2
INSTALL_USERWWW=$3
source $DIR/provisioners/shell/env.sh

declare -A plateforms
i=1

# we declare the first appplication
declare -A plateform1=(
    ["PLATEFORM_INSTALL_NAME"]="sfynx-nginx"
    ["PLATEFORM_INSTALL_TYPE"]=""
    ["PLATEFORM_INSTALL_VERSION"]=""
    ["PLATEFORM_PROJET_NAME"]="sfynx"
    ["PLATEFORM_PROJET_GIT"]=""
    ["DOMAINE"]=""
    ["MYAPP_BUNDLE_NAME"]=""
    ["MYAPP_PREFIX"]=""
    ["FOSUSER_PREFIX"]=""
)
for key in "${!plateform1[@]}"; do
  plateforms[$i,$key]=${plateform1[$key]}
done

# we declare the second appplication
declare -A plateform2=(
    ["PLATEFORM_INSTALL_NAME"]="nbi-nginx"
    ["PLATEFORM_INSTALL_TYPE"]=""
    ["PLATEFORM_INSTALL_VERSION"]=""
    ["PLATEFORM_PROJET_NAME"]="nosbelidees"
    ["PLATEFORM_PROJET_GIT"]=""
    ["DOMAINE"]=""
    ["MYAPP_BUNDLE_NAME"]=""
    ["MYAPP_PREFIX"]=""
    ["FOSUSER_PREFIX"]=""
)
((i++))
for key in "${!plateform2[@]}"; do
  plateforms[$i,$key]=${plateform2[$key]}
done

# we declare the third appplication
declare -A plateform3=(
    ["PLATEFORM_INSTALL_NAME"]="symfony-nginx"
    ["PLATEFORM_INSTALL_TYPE"]="composer"
    ["PLATEFORM_INSTALL_VERSION"]="2.4.0"
    ["PLATEFORM_PROJET_NAME"]="symfony24"
    ["PLATEFORM_PROJET_GIT"]=""
    ["DOMAINE"]="Dirisi"
    ["MYAPP_BUNDLE_NAME"]="Website"
    ["MYAPP_PREFIX"]="dirisi"
    ["FOSUSER_PREFIX"]="$MYAPP_PREFIX/admin"
)
((i++))
for key in "${!plateform3[@]}"; do
  plateforms[$i,$key]=${plateform3[$key]}
done

# we declare the fourth appplication
declare -A plateform4=(
    ["PLATEFORM_INSTALL_NAME"]="symfony-nginx"
    ["PLATEFORM_INSTALL_TYPE"]="composer"
    ["PLATEFORM_INSTALL_VERSION"]="2.7.0"
    ["PLATEFORM_PROJET_NAME"]="symfony27"
    ["PLATEFORM_PROJET_GIT"]=""
    ["DOMAINE"]="Dirisi"
    ["MYAPP_BUNDLE_NAME"]="Website"
    ["MYAPP_PREFIX"]="dirisi"
    ["FOSUSER_PREFIX"]="$MYAPP_PREFIX/admin"
)
((i++))
for key in "${!plateform4[@]}"; do
  plateforms[$i,$key]=${plateform4[$key]}
done

# we concatenate all applications
declare -p plateforms

# print value
matrix=(
    "PLATEFORM_INSTALL_NAME"
    "PLATEFORM_INSTALL_TYPE"
    "PLATEFORM_INSTALL_VERSION"
    "PLATEFORM_PROJET_NAME"
    "PLATEFORM_PROJET_GIT"
    "DOMAINE"
    "MYAPP_BUNDLE_NAME"
    "MYAPP_PREFIX"
    "FOSUSER_PREFIX"
)
for m in "${!matrix[@]}"
do
    echo "key: " $m "  value: ${matrix[$m]}"
done
num_rows=$i
num_columns=9
f1="%$((${#num_rows}+1))s"
f2=" %9s"

printf "$f1" ''
for ((i=1;i<=num_rows;i++)) do
    printf "$f2" plf$i
done
echo

for ((j=1;j<=num_columns;j++)) do
    printf "$f1" $j
    for ((i=1;i<=num_rows;i++)) do
        #printf "$f2" ${matrix[$j - 1]}
        printf "$f2" ${plateforms[$i,${matrix[$j - 1]}]}

    done
    echo
done




