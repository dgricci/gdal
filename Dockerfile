## GDAL - Geospatial Data Abstraction Library 
FROM dgricci/proj4:0.0.4
MAINTAINER Didier Richard <didier.richard@ign.fr>

ARG GDAL_VERSION
ENV GDAL_VERSION ${GDAL_VERSION:-2.2.3}
ARG GDAL_DOWNLOAD_URL
ENV GDAL_DOWNLOAD_URL ${GDAL_DOWNLOAD_URL:-http://download.osgeo.org/gdal/$GDAL_VERSION/gdal-$GDAL_VERSION.tar.gz}
ARG GDAL_AUTOTEST_DOWNLOAD_URL
ENV GDAL_AUTOTEST_DOWNLOAD_URL ${GDAL_AUTOTEST_DOWNLOAD_URL:-http://download.osgeo.org/gdal/$GDAL_VERSION/gdalautotest-$GDAL_VERSION.tar.gz}

COPY build.sh /tmp/build.sh

RUN /tmp/build.sh && rm -f /tmp/build.sh

# Externally accessible data is by default put in /geodata
# use -v at run time !
WORKDIR /geodata

# Output version and capabilities by default.
CMD gdalinfo --version && gdalinfo --formats && ogrinfo --formats

