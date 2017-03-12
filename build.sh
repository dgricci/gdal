#!/bin/bash

# Exit on any non-zero status.
trap 'exit' ERR
set -E

echo "Compiling GDAL ${GDAL_VERSION}..."
01-install.sh
# prevent libproj0, libproj-dev and proj-data to overwrite already compiled proj !
# jvm-7-avian-jre provides libjmv.so needed when with-java at execution time !
apt-mark hold libproj0 libproj-dev proj-data
apt-get -qy --no-install-recommends install \
    libarmadillo-dev \
    libcfitsio-dev \
    libcurl4-gnutls-dev \
    libdap-dev \
    libepsilon-dev \
    libfreexl-dev \
    libgeos-dev \
    libhdf4-alt-dev \
    libjasper-dev \
    libkml-dev \
    liblcms2-dev \
    liblzma-dev \
    libmysqlclient-dev \
    libpcre3-dev \
    libpodofo-dev \
    libpq-dev \
    libspatialite-dev \
    libwebp-dev \
    libxerces-c-dev \
    php5-dev \
    python-dev \
    unixodbc-dev \
    bash-completion \
    gpsbabel \
    hdf4-tools \
    libjasper-runtime \
    libmdb2 \
    libtiff-tools \
    netcdf-bin \
    odbcinst1debian2 \
    openjdk-7-jdk \
    jvm-7-avian-jre \
    pngtools \
    python-numpy \
    python-setuptools
echo "/usr/lib/jvm/java-7-openjdk-amd64/jre/lib/amd64/avian" >> /etc/ld.so.conf.d/java.conf && ldconfig

# compiling php :
# gdal_wrap.cpp:935:65: error: invalid conversion from ‘const char*’ to ‘char*’ [-fpermissive]
# add -fpermissive to swig/php/GNUmakefile
# TODO : http://mongoc.org/libmongoc/current/installing.html
#        https://mongodb.github.io/mongo-cxx-driver/mongocxx-v3/installation/
NPROC=$(nproc)
cd /tmp
wget --no-verbose "$GDAL_DOWNLOAD_URL"
wget --no-verbose "$GDAL_DOWNLOAD_URL.md5"
md5sum --strict -c gdal-$GDAL_VERSION.tar.gz.md5
tar xzf gdal-$GDAL_VERSION.tar.gz
rm -f gdal-$GDAL_VERSION.tar.gz*
{
    cd gdal-$GDAL_VERSION ; \
    touch config.rpath ; \
    ./configure \
        --prefix=/usr \
        --with-libz=/usr/lib/x86_64-linux-gnu \
        --with-liblzma=yes \
        --with-pg=/usr/bin/pg_config \
        --with-cfitsio=/usr/lib/x86_64-linux-gnu \
        --with-pcraster=internal \
        --with-png=internal \
        --with-libtiff=internal \
        --with-geotiff=internal \
        --with-jpeg=internal \
        --with-jpeg12 \
        --with-gif=internal \
        --with-hdf4=/usr \
        --with-netcdf=/usr \
        --with-jasper=/usr/lib/x86_64-linux-gnu \
        --with-mysql=/usr/bin/mysql_config \
        --with-xerces=yes \
        --with-libkml=yes \
        --with-odbc=/usr/lib/x86_64-linux-gnu \
        --with-curl=/usr/bin \
        --with-xml2=/usr/bin \
        --with-spatialite=yes \
        --with-sqlite3=yes \
        --with-pcre \
        --with-epsilon=yes \
        --with-webp=yes \
        --with-geos=yes \
        --with-qhull=internal \
        --with-freexl=yes \
        --with-libjson-c=internal \
        --with-podofo=yes \
        --with-php \
        --with-python \
        --with-java=/usr/lib/jvm/java-7-openjdk-amd64 \
        --with-mdb \
        --with-armadillo=yes && \
    sed -i -e 's/\(CFLAGS=-fpic\)/\1 -fpermissive/' swig/php/GNUmakefile && \
    make -j$NPROC > ../../make.log 2>&1 && \
    make install ; \
    ldconfig ; \
    cd .. ; \
    rm -fr gdal-$GDAL_VERSION ; \
}

# FIXME: run autotest ...

# don't auto-remove otherwise all libs are gone (not only headers) :
apt-get purge -y \
    libarmadillo-dev \
    libcfitsio-dev \
    libcurl4-gnutls-dev \
    libdap-dev \
    libepsilon-dev \
    libfreexl-dev \
    libgeos-dev \
    libhdf4-alt-dev \
    libjasper-dev \
    libkml-dev \
    liblcms2-dev \
    liblzma-dev \
    libmysqlclient-dev \
    libpcre3-dev \
    libpodofo-dev \
    libpq-dev \
    libspatialite-dev \
    libwebp-dev \
    libxerces-c-dev \
    php5-dev \
    python-dev \
    unixodbc-dev
01-uninstall.sh y

exit 0

