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
# cuda?
# s2
# h3
# https://github.com/sahrk/DGGRID
# aws command line
# open mp
# tensorflow
# pytorch
# keras
# pygrib

RUN sudo apt-get install libgflags-dev libgoogle-glog-dev libgtest-dev libssl-dev
RUN sudo apt-get install swig
RUN mkdir s2Source
RUN cd s2Source
RUN git clone https://github.com/google/s2geometry.git
RUN cd s2geometry
RUN mkdir build
RUN cd build
RUN cmake
RUN make
RUN make install



WORKDIR /data
CMD /bin/zsh