# weather-and-gis-docker
This is the Dockerfile for an image with a ton of weather, gis, and earth science based packages. It is intended to help ocean sailboat navigators get up and running quickly, but will hopefully also be useful for nerds with other goals.

The image is based on Ubuntu 18.04 and includes Python3.8.
Note that Python3.8 replaces Python2.7 entirely via a symlink.
This is probably a bad idea but it seems to work for my purposes.

# Included Linux Utilities and Libraries:
- tesseract
- imagemagick
- wget
- curl
- m4
- git
- cron
- HDF5
- NetCDF
- wgrib
- wgrib2
- gdal
- cdo

# Included Python3 Packages:
- metpy
- pytesseract
- python3-wget
- anaconda
- iris (conda only)
- ipython
- numpy
- matplotlib
- rasterio
- h5netcdf
- spicy
- netcdf4
- shapely
- scikit-learn
- scikit-image
- pandas
- geopandas
- geos
- cfgrib


# Installation and Use:
`docker build .`
// Wait like an hour
`docker images`
// Create a new container that can read/write to local directory "data"
`docker run -it --mount type=bind,source=$(pwd),target=/data <Image Id> /bin/bash'

# What can you do with this?
- Write a python script to pull down the png of an analysis or ascat image and make white space transparent,
- Reproject images, 
- Script grib analysis,
- Run this in the cloud and build a server to parse and push grib excerpts while you're sailing, 
- Probably a lot of other thigns. 

