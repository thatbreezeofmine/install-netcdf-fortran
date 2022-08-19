#!/bin/sh
#
# install_netcdf.sh
# Copyright (C) 2018 Daniel Santiago <dpelaez@cicese.edu.mx>
#
# Distributed under terms of the GNU/GPL license.
#
set -e


# ============================================================================
#  Installation of NetCDF4 Fortran libraries
# ----------------------------------------------------------------------------
#  
#  Purpose:
#    This script get the given versions of the NetCD4 libreries and its
#    dependencies and install them in the MAINDIR=/usr/local/netcdf/ directory
# 
#  Usage:
#    [sudo] CC=gcc FC=gfortran MAINDIR=/usr/local/netcdf ./install_netcdf.sh
# 
#  Autor:
#    Daniel Santiago
#    github/dspelaez
#
#  Edit:
#    Added the installation of gfortran and gcc compilers
#
#  Editor:
#    Nassim Chabchi
#    github/thatbreezeofmine
#
# ============================================================================

# install compilers
apt-get update
apt-get install build-essential -y
apt-get install gfortran -y
apt-get install m4 -y


## define compilers
CC=${CC:-gcc}
FC=${FC:-gfortran}
F90=${FC}
F77=${FC}

# main directory
MAINDIR=${MAINDIR:-/usr/local/netcdf}

# version of libs
CLTAG="7.61.0"
ZLTAG="1.2.10"
H5TAG="1.10.1"
NCTAG="4.6.1"
NFTAG="4.4.4"

# ## donwload source code of depencies
wget -nc -nv https://curl.haxx.se/download/curl-$CLTAG.tar.gz
wget -nc -nv https://zlib.net/fossils/zlib-$ZLTAG.tar.gz
wget -nc -nv https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-$H5TAG/src/hdf5-$H5TAG.tar 
wget -nc -nv ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-$NCTAG.tar.gz
wget -nc -nv ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-fortran-$NFTAG.tar.gz

## create config.log
touch config.log

## curl
tar -xf curl-$CLTAG.tar.gz
cd curl-$CLTAG/
CLDIR=$MAINDIR
echo " --->> Compiling curl-$CLTAG"
./configure --prefix=${CLDIR} > config.log 2>&1
make -j4 > config.log 2>&1
make install > config.log 2>&1
cd ..
rm -rf curl-$CLTAG


## zlib 
tar -xf zlib-$ZLTAG.tar.gz
cd zlib-$ZLTAG/
ZDIR=$MAINDIR
echo " --->> Compiling zlib-$ZLTAG"
./configure --prefix=${ZDIR} > config.log 2>&1
make -j4 > config.log 2>&1
make install > config.log 2>&1
cd ..
rm -rf zlib-$ZLTAG

## hdf5
tar -xf hdf5-$H5TAG.tar
cd hdf5-$H5TAG/
H5DIR=$MAINDIR
echo " --->> Compiling hdf5-$H5TAG"
./configure --with-zlib=${ZDIR} --prefix=${H5DIR} > config.log 2>&1
make -j4 > config.log 2>&1
make install > config.log 2>&1
cd ..
rm -rf hdf5-$H5TAG

## netcdf4-c
tar -xf netcdf-$NCTAG.tar.gz
cd netcdf-$NCTAG/
NCDIR=$MAINDIR
echo " --->> Compiling netcdf-$NCTAG"
CPPFLAGS=-I${H5DIR}/include LDFLAGS=-L${H5DIR}/lib ./configure --prefix=${NCDIR} > config.log 2>&1
make -j4
make install
cd ..
rm -rf netcdf-$NCTAG

## netcdf4-fortran
tar -xf netcdf-fortran-$NFTAG.tar.gz
cd netcdf-fortran-$NFTAG/
NFDIR=$MAINDIR
echo " --->> Compiling netcdf-fortran-$NFTAG"
CPPFLAGS=-I${NFDIR}/include LDFLAGS=-L${NFDIR}/lib ./configure --prefix=${NFDIR} > config.log 2>&1
make -j4 > config.log 2>&1
make install > config.log 2>&1
cd ..
rm -rf netcdf-fortran-$NFTAG

## show compilation options
$NCDIR/bin/nf-config --all

echo ""
echo ===============================================================================
echo "Finally, you must add this to the .profile (or .bashrc or .zshrc) file"
echo "  Linux --\>" export LD_LIBRARY_PATH=$NCDIR/lib:'$LD_LIBRARY_PATH'
echo ===============================================================================
echo ""
