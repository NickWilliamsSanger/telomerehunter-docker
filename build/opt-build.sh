#!/bin/bash

set -ex

if [[ -z "${TMPDIR}" ]]; then
  TMPDIR=/tmp
fi

set -u

if [ "$#" -lt "1" ] ; then
  echo "Please provide an installation path such as /opt/ICGC"
  exit 1
fi

# get path to this script
SCRIPT_PATH=`dirname $0`;
SCRIPT_PATH=`(cd $SCRIPT_PATH && pwd)`

# get the location to install to
INST_PATH=$1
mkdir -p $1
INST_PATH=`(cd $1 && pwd)`
echo $INST_PATH

# get current directory
INIT_DIR=`pwd`

pip install --prefix=$INST_PATH pysam==0.9.0 PyPDF2==1.26.0 telomerehunter

#Now fetch and install R 3.3.0
curl -sSL --retry 10 https://cran.rstudio.com/src/base/R-3/R-3.3.0.tar.gz > R-3.3.0.tar.gz
tar -zxf R-3.3.0.tar.gz
cd R-3.3.0
./configure --prefix=$INST_PATH --with-cairo=yes --enable-R-shlib --with-x=no
make
make check
make install

export R_LIBS=$INST_PATH/R-lib
export R_LIBS_USER=$R_LIBS

#Add the relevant packages
cd $INIT_DIR
Rscript $SCRIPT_PATH/libInstall.R $R_LIBS_USER 2>&1 | grep '^\*'
