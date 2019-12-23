# weather-and-gis-docker
This is the Dockerfile for an image with a ton of weather, gis, and earth science based packages. It is intended to help ocean sailboat navigators get up and running quickly, but will hopefully also be useful to nerds with other goals.

The image is based on Ubuntu 18.04 and includes Python3.8.
Note that Python3.8 replaces Python2.7 entirely via a symlink.
This is probably a bad idea but it seems to work for my purposes.

# Why Docker?
You may have very little experience with software development or navigating complicated documentation written by brilliant scientists working for government agencies. Nevertheless, you should be able to benefit from the incredible software available to you. Docker allows an ocean navigator or curious enthusiast to install and use various utilties on any kind of computing system without needing to know too much.  

- You can access the same programs on your home computer and the boat's nav computer.  
- You can use all the same utils used by various weather bureaus without needing to build them yourself.  
- You can install a ton of utilities with one command.  
- We can build a community and shared knowledge base using the same tool set.  
- Docker machines can see files on your local machine and vice versa.  
- You can run this at home or in the cloud, ssh into it from your boat, do your analysis and only pull down a smaller excerpt of data.  
- Linux utils have offline man pages for help and documentation.  

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
- eccodes
- cdo
- zsh + oh my zsh
- emacs
- tmux  
- conda

# Included Python3 Packages:
- metpy
- pytesseract
- python3-wget
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
- cftime
- cfunits
- iris (conda only)
- jupyter
- scipy
- cython
- cartopy


# Installation and Use:

```
$ docker build -t weather_image:1.0 .  
// Wait a few hours  ...  
// Create a new container that can read/write to local directory.  
$ docker run -it --mount type=bind,source=$(pwd),target=/data --name weather_shell weather_image:1.0  /bin/zsh  
// Then later after you exit your container, to get back into it:  
$ docker start -a weather_shell
```

# What can you do with this?
- Write a python script to pull down the png of an analysis or ascat image and make white space transparent,
- Extract text from images pulled down from NOAA,
- Reproject images, 
- Script grib analysis,
- Convert NetCDF to Grib2,
- List grib messages,
- Extract a region of a grib file,
- Run this in the cloud and build a server to parse and push grib excerpts while you're sailing, 
- Write a script to build a KML from your Expedition log, 
- Probably a lot of other things. 

# Examples:
Problem: I have historical data in NetCDF format that Expedition doesn't recognize.  
Solution: Convert it to Grib2 and rename the messages using CDO and wgrib2 like so:  

```
$ cdo -f grb2 copy stupid_netcdf.nc broken_grib.grb  
\\ Then inspect the broken grib messages and find the one that needs to be fixed: 
$ wgrib2 broken_grib.grb  
\\ Replace the message directions:  
$ wgrib2 broken_grib.grb -if ":erroneous grib message" -set_lev "10 m above ground" -fi -grib fixed_grib.grb
```  

Problem: I found hourly historical data but it's 25 gigabytes and GRIB1 and I can't load it!  
Solution: Slice it by the region you care about using cdo.  

```
$ cdo -sellonlatbox,-162,-116,-25,35 big_grib.grb smaller_grib.grb
```  

Problem: I've georeferenced an ASCAT image but the white background is annoying. Is there a way to erase it?   
Solution: Yes! Use ImageMagick to erase the white background, leaving only wind barbs and text behind!  

```
$ convert  ascat.jpg -transparent white ascat_transparent.jpg
```  

Problem: I have a python script and I want it to call some program.  
Solution: Use os.system('command')  

```
// Within your script ...
os.system('convert ascat.jpg -transparent white ascat_transparent.jpg')
```

# Where to go for help:  
- https://docker-curriculum.com/ Has a good get started guide for Docker.  
- Consult the documentation for the various tools on the image.  

# System Requirements:
- Docker Desktop
- A beefy machine (containers run about 4 gb)