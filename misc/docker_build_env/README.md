## How to setup GLM building environment with Docker
### Download the repositories
Prepare your working copy of GLM source files and its dependancies (e.g. a root folder named `AED_Tools`. For a minimal installation of GLM (no plots), you need to clone the following repositories:

~~~bash
git clone https://github.com/AquaticEcoDynamics/libaed2.git
git clone https://github.com/AquaticEcoDynamics/libutil.git
git clone git://git.code.sf.net/p/fabm/code fabm-git
git clone https://github.com/d-vanzo/GLM.git
~~~

Note that the last repository is a fork of the official GLM project.

### Setup a Docker container
1. Install the [_docker_](https://www.docker.com/
) engine (community edition), as explained [here](https://docs.docker.com/install/).
2. I prepare a ready-to-use *Dockerfile* with all the needed packages, so open the terminal inside the folder `GLM/misc/docker_build_env/` where the Dockerfile is located.
3. WATCH! For Linux and (maybe) MacOS users: by default _docker engine_ requires root privileges, i.e. you have to type `sudo` in front of each of the following commands. If you wish to avoid this, you can follow this [guidelines](https://docs.docker.com/install/linux/linux-postinstall/#manage-docker-as-a-non-root-user).
4. Build the docker image using the given Dockerfile

    ~~~bash
    docker build -t glm:ubuntu18 .
    ~~~

5. Create the actual docker container (that makes use of the image you just created), remebering to provide the `<pathToLocalGitRepoDirectory>`:

    ~~~bash
    docker create --name glm -it -v <pathToLocalGitRepoDirectory>:/home/AED_Tools glm:ubuntu18
    ~~~

6. A container named `glm` has just been created, now let's start it:

    ~~~bash
    docker start glm
    ~~~

7. Your container is now running, to jump into it, open a `bash` terminal with:

    ~~~bash
    docker exec -it glm bash
    ~~~

8. If everything went smooth, you're now inside your virtual build environment at the path `/home/AED_Tools`, which is mapping your local directory at `<pathToLocalGitRepoDirectory>`, as example.

9. Next time you want to access the container, simply execute points 6 and 7 (even just 7 if your container is already running). Now you are ready to actually build GLM.

### Build GLM
Jump into `GLM` folder and simply execute the shell script `./build_glm.sh`.
To change the default building configuration you can modify the `GLM_CONFIG` file, but be careful, you might break the build toolchain.

Enjoy your GLM simulations!
