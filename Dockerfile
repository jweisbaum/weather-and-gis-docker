FROM ubuntu:18.04


LABEL maintainer "NVIDIA CORPORATION <cudatools@nvidia.com>"

RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg2 curl ca-certificates && \
    curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub | apt-key add - && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
    echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list && \
    apt-get purge --autoremove -y curl \
    && rm -rf /var/lib/apt/lists/*

ENV CUDA_VERSION 11.1.1

# For libraries in the cuda-compat-* package: https://docs.nvidia.com/cuda/eula/index.html#attachment-a
RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-cudart-11-1=11.1.74-1 \
    cuda-compat-11-1 \
    && ln -s cuda-11.1 /usr/local/cuda && \
    rm -rf /var/lib/apt/lists/*

# Required for nvidia-docker v1
RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=11.1 brand=tesla,driver>=418,driver<419 brand=tesla,driver>=440,driver<441 brand=tesla,driver>=450,driver<451"

ENV NCCL_VERSION 2.7.8

RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-libraries-11-1=11.1.1-1 \
    libnpp-11-1=11.1.2.301-1 \
    cuda-nvtx-11-1=11.1.74-1 \
    libcublas-11-1=11.3.0.106-1 \
    libnccl2=$NCCL_VERSION-1+cuda11.1 \
    && apt-mark hold libnccl2 \
    && rm -rf /var/lib/apt/lists/*



RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN apt-get install software-properties-common -y
RUN add-apt-repository ppa:ubuntugis/ppa

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata

RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime
RUN dpkg-reconfigure --frontend noninteractive tzdata

RUN apt-get update \
    && apt-get install tesseract-ocr -y \
	python3.8 \
	python3-pip \
	python3-setuptools \
    python3-opencv \
    python3-scipy \
    python3-matplotlib \
	wget \
	curl \
    	gfortran \
    	gcc \
	wget \
	make \
    m4 \
    git \
    cron \
    emacs \
    nano \
    tmux \
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

# Install Node
RUN curl -sL https://deb.nodesource.com/setup_15.x | bash - \
    && apt-get install -y nodejs

RUN rm -f /usr/bin/python && ln -s /usr/bin/python3 /usr/bin/python

RUN pip3 install metpy

RUN pip3 install pytesseract \
    && pip3 install python3-wget


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

RUN cp grib2/wgrib2/wgrib2 /usr/local/bin \
    && rm -rf grib2 \
    && rm wgrib2.tgz

#Install ImageMagick
RUN cd /opt \
    && wget http://www.imagemagick.org/download/ImageMagick.tar.gz \
    && tar xvzf ImageMagick.tar.gz \
    && for dir in ImageMagick*;do mv $dir ImageMagick;done \
    && cd ImageMagick \
    && touch configure \
    && ./configure \
    && make \
    && make install \
    && ldconfig /usr/local/lib \
    && cd .. \
    && rm -rf ImageMagick \
    && rm -rf ImageMagick.tar.gz


RUN apt-get install cdo -y

RUN apt-get install gdal-bin -y \
    && apt-get install libgdal-dev -y

RUN apt-get install libxml2 libxml2-dev \
    language-pack-en \
    libz-dev \
    libncurses-dev \
    libbz2-dev \
    liblzma-dev \
    libudunits2-dev -y 

RUN pip3 --no-cache-dir install --upgrade \
        setuptools \
        wheel

RUN pip3 install Cython

RUN apt-get install libproj-dev proj-data proj-bin unzip -y \
    && apt-get install libgeos-dev -y \
    && apt-get install libpdal-dev pdal libpdal-plugin-python -y

# RUN cd /tmp \
#     && wget -c https://download.osgeo.org/proj/proj-datumgrid-world-latest.zip \
#     && wget -c https://download.osgeo.org/proj/proj-datumgrid-oceania-latest.zip \
#     && wget -c https://download.osgeo.org/proj/proj-datumgrid-north-america-latest.zip \
#     && wget -c https://download.osgeo.org/proj/proj-datumgrid-europe-latest.zip \
#     && cd /usr/share/proj/ \
#     && for datumfile in $(ls /tmp/proj-datumgrid-*-latest.zip) ; do unzip $datumfile && rm -f $datumfile; done


RUN pip3 install numpy \
	&& pip3 install matplotlib \
	&& pip3 install rasterio \
	&& pip3 install h5netcdf \
	&& pip3 install spicy \
	&& pip3 install netcdf4 \
	&& pip3 install shapely \
	&& pip3 install sklearn \
	&& pip3 install scikit-image \
    && pip3 install pandas 

# pip3 install geopandas
# pip3 install geos

RUN apt-get install libeccodes0 \
    && pip3 install cfgrib

# Wgrib1
RUN wget ftp://ftp.cpc.ncep.noaa.gov/wd51we/wgrib/wgrib.tar \
    && mkdir wgrib1 \
    && tar -C wgrib1 -xvf wgrib.tar \
    && rm wgrib.tar \
    && cd wgrib1 \
    && make \
    && cp wgrib /usr/bin \
    && cd .. \
    && rm -rf wgrib1 

RUN git clone https://github.com/powerline/fonts.git --depth=1 \
    && cd fonts \
    && ./install.sh \
    && cd .. \
    && rm -rf fonts 

ENV ZSH_THEME avit
# Oh my zsh
RUN apt-get install zsh fonts-powerline -y \
    && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    && chsh -s $(which zsh)


# CMake
RUN wget https://github.com/Kitware/CMake/releases/download/v3.15.2/cmake-3.15.2.tar.gz \
    && tar -zxvf cmake-3.15.2.tar.gz \
    && cd cmake-3.15.2 \
    && ./bootstrap \
    && make \
    && make install \
    && cd .. \
    && rm cmake-3.15.2.tar.gz \
    && rm -rf cmake-3.15.2

# ecCODES
RUN wget https://confluence.ecmwf.int/download/attachments/45757960/eccodes-2.15.0-Source.tar.gz \
    && tar -xzf  eccodes-2.15.0-Source.tar.gz \
    && mkdir buildeccode \
    && cd buildeccode \
    && cmake ../eccodes-2.15.0-Source \
    && make \
    && ctest \
    && make install \
    && cd .. \
    && rm -rf buildeccode \
    && rm eccodes-2.15.0-Source.tar.gz \
    && rm -rf eccodes-2.15.0-Source \
    && pip3 install eccodes-python 

RUN pip3 install scipy ipython jupyter sympy nose

# Conda and Iris
RUN cd /tmp \
    && curl -O https://repo.anaconda.com/archive/Anaconda3-2019.03-Linux-x86_64.sh \
    && bash Anaconda3-2019.03-Linux-x86_64.sh -b \
    && rm Anaconda3-2019.03-Linux-x86_64.sh 
ENV PATH ~/anaconda3/bin:$PATH
RUN ~/anaconda3/bin/conda update conda
RUN ~/anaconda3/bin/conda update --all
RUN ~/anaconda3/bin/conda install -c conda-forge iris pynio pyngl ncl 


RUN git clone https://github.com/NCAR/wrf-python \
    && cd wrf-python \
    && pip3 install .


RUN pip3 install cartopy cftime oktopus tqdm cf-units dask stratify pyugrid
RUN apt-get install -y aptitude
RUN aptitude install nco -y

# https://github.com/cambecc/grib2json
# RUN git clone https://github.com/cambecc/grib2json.git \
#     && cd grib2json \
#     && 
# https://www.npmjs.com/package/grib2json
# Open CV
# WRT
# Jupyter, iPython
# s2
# h3
# https://github.com/sahrk/DGGRID
# aws command line
# open mp
# tensorflow
# pytorch
# keras
# pygrib
# https://github.com/Unidata/netcdf-java
# https://github.com/Unidata/thredds
# https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compilation_tutorial.php#STEP7
# https://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
# https://www.cgal.org/
# https://mpitutorial.com/tutorials/launching-an-amazon-ec2-mpi-cluster/
# http://mpas-dev.github.io/
# https://wrf-python.readthedocs.io/en/latest/
# https://www.mi.uni-hamburg.de/en/arbeitsgruppen/memi/modelle/metras.html
# https://www.mi.uni-hamburg.de/en/arbeitsgruppen/memi/modelle/mitras.html
# http://homepages.see.leeds.ac.uk/~lecag/microscale/index.html
# 

######## S2 ##############
# RUN apt-get install libgflags-dev libgoogle-glog-dev libgtest-dev libssl-dev swig
# RUN mkdir s2Source \
#     && cd s2Source \
#     && git clone https://github.com/google/s2geometry.git \
#     && cd s2geometry \
#     && mkdir build \
#     && cd build \
#     && cmake ..\
#     && make \
#     && make install


RUN apt-get install csh


####################################
##Additional linux and command-line tools
#Install add-apt-repository. This needs to be done starting Ubuntu 16.x
RUN apt-get update \
	&& apt-get install -yq --no-install-recommends \
	software-properties-common \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

RUN add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main"
RUN apt update
RUN apt install libjasper1 libjasper-dev

####################################
##WRF, WRF-Hydro, and WPS dependencies and tools used for compilation
RUN apt-get update \
    && apt-get install -yq --no-install-recommends \
    vim \
    nano \
    wget \
    curl \
    file \
    bzip2 \
    ca-certificates \
    libhdf5-dev \
    gfortran \
    openmpi-bin \
    libopenmpi-dev \
    valgrind \
    m4 \
    make \ 
    libswitch-perl \
    git \
    csh \
    bc \
    libpng-dev \
    libjasper-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* 


## install netCDF-C
ENV NCDIR=/usr/local
ENV NFDIR=/usr/local
ENV H5DIR=/usr/lib/x86_64-linux-gnu/hdf5/serial
ENV HDF5_DIR=/usr/lib/x86_64-linux-gnu/hdf5/serial

RUN NETCDF_C_VERSION="4.4.1.1" \
    && wget ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-${NETCDF_C_VERSION}.tar.gz -P /tmp \
    && tar -xf /tmp/netcdf-${NETCDF_C_VERSION}.tar.gz -C /tmp \
    && cd /tmp/netcdf-${NETCDF_C_VERSION} \
    && CPPFLAGS=-I${H5DIR}/include LDFLAGS=-L${H5DIR}/lib ./configure --prefix=/usr/local \
    && cd /tmp/netcdf-${NETCDF_C_VERSION} \
    && make \
    && cd /tmp/netcdf-${NETCDF_C_VERSION} \
    && make install \
    && rm -rf /tmp/netcdf-${NETCDF_C_VERSION}

# install netCDF-Fortran
ENV LD_LIBRARY_PATH=${NCDIR}/lib
RUN NETCDF_F_VERSION="4.4.4" \
    && cd /tmp \
    && wget ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-fortran-${NETCDF_F_VERSION}.tar.gz \
    && tar -xf netcdf-fortran-${NETCDF_F_VERSION}.tar.gz \
    && cd /tmp/netcdf-fortran-${NETCDF_F_VERSION} \
    && CPPFLAGS=-I${NCDIR}/include LDFLAGS=-L${NCDIR}/lib ./configure --prefix=${NFDIR} \
    && make \
    && make install \
    && cd / \
    && rm -rf /tmp/netcdf-fortran-${NETCDF_F_VERSION}


###################################
## create docker user
RUN useradd -ms /bin/bash docker
RUN usermod -aG sudo docker
RUN chmod -R 777 /home/docker/
############################

###WRF | WRF-Hydro and WPS

#Set WRF and WPS version argument
ARG WRF_VERSION="4.1.2"
ARG WPS_VERSION="4.1"

#Set WRF-Hydro version argument
ARG HYDRO_VERSION="5.1.1-beta"

#Install coupled WRF | WRF-Hydro AND WPS
WORKDIR /home/docker/WRF_WPS
#
# Download sources for versions specified by the WRFWPS_VERSION and HYDRO_VERSION arguments
#
RUN wget https://github.com/wrf-model/WRF/archive/v${WRF_VERSION}.tar.gz \
        && tar -zxf v${WRF_VERSION}.tar.gz \
        && mv WRF-${WRF_VERSION} WRF \
        && rm v${WRF_VERSION}.tar.gz
#RUN wget https://github.com/NCAR/wrf_hydro_nwm_public/archive/v${HYDRO_VERSION}.tar.gz \
#        && tar -zxf v${HYDRO_VERSION}.tar.gz \
#        && rm -r WRF/hydro \
#        && cp -r wrf_hydro_nwm_public*/trunk/NDHMS WRF/hydro \
#        && rm v${HYDRO_VERSION}.tar.gz
RUN git clone --single-branch --branch v5.1.1 https://github.com/NCAR/wrf_hydro_nwm_public.git \
        && rm -r WRF/hydro \
        && cp -r wrf_hydro_nwm_public*/trunk/NDHMS WRF/hydro 
RUN wget https://github.com/wrf-model/WPS/archive/v${WPS_VERSION}.tar.gz \
	&& tar -zxf v${WPS_VERSION}.tar.gz \
        && mv WPS-${WPS_VERSION} WPS \
	&& rm v${WPS_VERSION}.tar.gz

# Set paths to required libraries
ENV JASPERLIB=/usr/lib
ENV JASPERINC=/usr/include
ENV NETCDF=/usr/local

# Set WRF-Hydro environment variables
ENV WRF_HYDRO=1
ENV HYDRO_D=1
ENV SPATIAL_SOIL=0
ENV WRF_HYDRO_RAPID=0
ENV WRFIO_NCD_LARGE_FILE_SUPPORT=1
ENV WRF_HYDRO_NUDGING=0

# Build WRF first, required for WPS
WORKDIR /home/docker/WRF_WPS/WRF
RUN printf '34\n1\n' | ./configure \
	&& ./compile em_real  

# Build WPS second after WRF is built
WORKDIR /home/docker/WRF_WPS/WPS
RUN printf '1\n' | ./configure \
	&& ./compile 

RUN chmod -R 777 /home/docker/WRF_WPS

# This is in accordance to : https://www.digitalocean.com/community/tutorials/how-to-install-java-with-apt-get-on-ubuntu-16-04
RUN apt-get update && \
	apt-get install -y openjdk-8-jdk && \
	apt-get install -y ant && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /var/cache/oracle-jdk8-installer;
	
# Fix certificate issues, found as of 
# https://bugs.launchpad.net/ubuntu/+source/ca-certificates-java/+bug/983302
RUN apt-get update && \
	apt-get install -y ca-certificates-java && \
	apt-get clean && \
	update-ca-certificates -f && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /var/cache/oracle-jdk8-installer;

# Setup JAVA_HOME, this is useful for docker commandline
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
RUN export JAVA_HOME


# Install maven 3.3.9
RUN wget --no-verbose -O /tmp/apache-maven-3.3.9-bin.tar.gz http://www-eu.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz && \
    tar xzf /tmp/apache-maven-3.3.9-bin.tar.gz -C /opt/ && \
    ln -s /opt/apache-maven-3.3.9 /opt/maven && \
    ln -s /opt/maven/bin/mvn /usr/local/bin  && \
    rm -f /tmp/apache-maven-3.3.9-bin.tar.gz

ENV MAVEN_HOME /opt/maven

RUN apt-get update && apt-get install -y \
	        curl \
	        wget \
	        unzip && \
	        wget https://github.com/cambecc/grib2json/archive/master.zip && \
	        unzip master.zip && \
	        cd grib2json-master && \
	        mvn package && \
	        cd target && \
	        tar -xvf grib2json-0.8.0-SNAPSHOT.tar.gz && \
	        cp grib2json-*/bin/* /usr/bin && \
	        cp grib2json-*/lib/* /usr/lib






WORKDIR /data
CMD /bin/zsh