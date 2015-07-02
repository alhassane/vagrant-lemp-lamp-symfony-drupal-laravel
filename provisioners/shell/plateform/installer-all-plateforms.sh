#!/bin/bash
DIR=$1
DISTRIB=$2
INSTALL_USERWWW=$3
source $DIR/provisioners/shell/env.sh

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
for ((i=1;i<=num_rows;i++))
do
    printf "$f2" plf$i
done
echo

for ((j=1;j<=num_columns;j++))
do
    printf "$f1" $j
    for ((i=1;i<=num_rows;i++))
    do
        #printf "$f2" ${matrix[$j - 1]}
        printf "$f2" ${plateforms[$i,${matrix[$j - 1]}]}
    done
    echo
done


for ((i=1;i<=num_rows;i++))
do
    # we redeclare parameters
    PLATEFORM_INSTALL_NAME=${plateforms[$i,${matrix[0]}]}
    PLATEFORM_INSTALL_TYPE=${plateforms[$i,${matrix[1]}]}
    PLATEFORM_INSTALL_VERSION=${plateforms[$i,${matrix[2]}]}
    PLATEFORM_PROJET_NAME=${plateforms[$i,${matrix[3]}]}
    PLATEFORM_PROJET_GIT=${plateforms[$i,${matrix[4]}]}
    DOMAINE=${plateforms[$i,${matrix[5]}]}
    MYAPP_BUNDLE_NAME=${plateforms[$i,${matrix[6]}]}
    MYAPP_PREFIX=${plateforms[$i,${matrix[7]}]}
    FOSUSER_PREFIX=${plateforms[$i,${matrix[8]}]}
    source $DIR/provisioners/shell/plateform/var.sh

    echo "**** we install plateform ****"
    $DIR/provisioners/shell/plateform/installer-$PLATEFORM_INSTALL_NAME.sh "$DIR" "$DISTRIB" "$INSTALL_USERWWW" "$PLATEFORM_INSTALL_NAME" "$PLATEFORM_INSTALL_TYPE" "$PLATEFORM_INSTALL_VERSION" "$PLATEFORM_PROJET_NAME" "$PLATEFORM_PROJET_GIT" "$DOMAINE" "$MYAPP_BUNDLE_NAME" "$MYAPP_PREFIX" "$FOSUSER_PREFIX"

    echo "we install the mysql dump files if the $DIR/DUMP/mysqldump_$DATABASE_NAME.sql file exist"
    if [ -f "$DIR/DUMP/mysqldump_$DATABASE_NAME.sql" ]; then
        sudo $DIR/provisioners/shell/plateform/importBDD.sh "$DIR/DUMP/mysqldump_$DATABASE_NAME.sql" "$DATABASE_NAME"
    fi

    echo "we install all uploads files if the $DIR/DUMP/uploads_$DATABASE_NAME.tar.gz file exist"
    if [ -f "$DIR/DUMP/uploads_$DATABASE_NAME.sql" ]; then
        sudo $DIR/provisioners/shell/plateform/importUpload.sh "$DIR/DUMP/uploads_$DATABASE_NAME.tar.gz" "$DIR" "$INSTALL_USERWWW" "$PLATEFORM_PROJET_NAME"
    fi

    echo "we install the jackribbit database if the $DIR/DUMP/jr_$DATABASE_NAME.tar.gz file exist"
    if [ -f "$DIR/DUMP/jr_$DATABASE_NAME.sql" ]; then
        sudo $DIR/provisioners/shell/plateform/importJR.sh "$DIR/DUMP/jr_$DATABASE_NAME.tar.gz"
    fi 
done
