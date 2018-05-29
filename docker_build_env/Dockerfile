FROM ubuntu:18.04
MAINTAINER SURF Team "davide.vanzo@eawag.ch"

# get the tools we need
RUN apt-get update && \
	apt-get install -y libnetcdf-dev libgd-dev libx11-dev && \
	cmake gfortran-8 lsb_release dh-make electric-fence

# define the default gnu compile suite version
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 100
RUN update-alternatives --install /usr/bin/gfortran gfortran /usr/bin/gfortran-8 100

# root dir
RUN mkdir /home/AED_Tools
WORKDIR /home/AED_Tools

# calls that are needed to build and start the container with the build environment:
# docker build -t glm:ubuntu18 .
# docker create --name glm -it -v <pathToLocalGitRepoDirectory>:/home/AED_Tools glm:ubuntu18
# docker start glm
# docker exec -it glm bash
