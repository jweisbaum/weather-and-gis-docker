FROM ubuntu:18.04

RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN apt-get install software-properties-common -y
RUN add-apt-repository ppa:ubuntugis/ppa

RUN apt-get update \
    && apt-get install tesseract-ocr -y \
	python3.8 \
	python3-pip \
	python3-setuptools \
	wget \
	curl \
    	gfortran \
    	gcc \
	wget \
	make \
	build-essential \
	checkinstall \
	libx11-dev \
	libxext-dev \
	zlib1g-dev \
	libpng-dev \
	libjpeg-dev \
	libfreetype6-dev \
	libxml2-dev \
    && apt-get clean \
    && apt-get autoremove

RUN rm -f /usr/bin/python && ln -s /usr/bin/python3 /usr/bin/python

RUN pip3 install metpy

RUN pip3 install pytesseract \
    && pip3 install python3-wget

RUN apt-get update && apt-get install -y cron
RUN apt-get install m4 -y
RUN apt-get install git -y

# HDF5 Installation
RUN wget https://www.hdfgroup.org/package/bzip2/?wpdmdl=4300 \
        && mv "index.html?wpdmdl=4300" hdf5-1.10.1.tar.bz2 \
        && tar xf hdf5-1.10.1.tar.bz2 \
        && cd hdf5-1.10.1 \
        && ./configure --prefix=/usr --enable-cxx --with-zlib=/usr/include,/usr/lib/x86_64-linux-gnu \
        && make -j4 \
        && make install \
        && cd .. \
        && rm -rf hdf5-1.10.1 \
        && rm -rf hdf5-1.10.1.tar.bz2

# NetCDF Installation
RUN wget https://github.com/Unidata/netcdf-c/archive/v4.4.1.1.tar.gz \
        && tar xf v4.4.1.1.tar.gz \
        && cd netcdf-c-4.4.1.1 \
        && ./configure --prefix=/usr \
        && make -j4 \
        && make install \
        && cd .. \
        && rm -rf netcdf-c-4.4.1.1 \
        && rm -rf v4.4.1.1.tar.gz


# Install wgrib2
RUN wget http://www.ftp.cpc.ncep.noaa.gov/wd51we/wgrib2/wgrib2.tgz

ENV CC gcc
ENV FC gfortran
ENV USE_NETCDF3 0
ENV USE_NETCDF4 1

RUN tar -xzf wgrib2.tgz \
  && cd grib2 \
  && make
RUN cp grib2/wgrib2/wgrib2 /usr/local/bin

#Install ImageMagick
RUN cd /opt \
    && wget http://www.imagemagick.org/download/ImageMagick.tar.gz \
    && tar xvzf ImageMagick.tar.gz \
    && cd ImageMagick-7.0.9-9 \
    && touch configure \
    && ./configure \
    && make \
    && make install \
    && ldconfig /usr/local/lib

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata

RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime
RUN dpkg-reconfigure --frontend noninteractive tzdata
RUN apt-get install cdo -y

RUN apt-get install gdal-bin -y \
    && apt-get install libgdal-dev -y


RUN pip3 install numpy \
	&& pip3 install matplotlib \
	&& pip3 install rasterio \
	&& pip3 install h5netcdf \
	&& pip3 install spicy \
	&& pip3 install netcdf4 \
	&& pip3 install shapely \
	&& pip3 install sklearn \
	&& pip3 install scikit-image \
	&& pip3 install geopandas \
	&& pip3 install geos

RUN apt-get install libeccodes0 \
    && pip3 install cfgrib

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH /opt/conda/bin:$PATH

RUN apt-get update --fix-missing \
    && apt-get install -y wget bzip2 ca-certificates libglib2.0-0 libxext6 libsm6 libxrender1 mercurial subversion \
    && apt-get clean

RUN wget --quiet https://repo.anaconda.com/archive/Anaconda2-2019.10-Linux-x86_64.sh -O ~/anaconda.sh \
    && /bin/bash ~/anaconda.sh -b -p /opt/conda \
    && rm ~/anaconda.sh \
    && ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh \
    && echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc \
    && echo "conda activate base" >> ~/.bashrc \
    && find /opt/conda/ -follow -type f -name '*.a' -delete \
    && find /opt/conda/ -follow -type f -name '*.js.map' -delete \
    && /opt/conda/bin/conda clean -afy

RUN conda install -c conda-forge iris

RUN wget ftp://ftp.cpc.ncep.noaa.gov/wd51we/wgrib/wgrib.tar \
    && mkdir wgrib1 \
    && tar -C wgrib1 -xvf wgrib.tar \
    && rm wgrib.tar \
    && cd wgrib1 \
    && make \
    && cp wgrib /usr/bin \
    && cd .. \
    && rm -rf wgrib1

# Oh my zsh
RUN apt-get install zsh fonts-powerline -y \
    && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    && chsh -s $(which zsh)

# TODO: degrib

WORKDIR /data
CMD /bin/sh