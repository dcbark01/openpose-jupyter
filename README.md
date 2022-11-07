# Overview

This repo contains simple code for using [OpenPose](https://github.com/CMU-Perceptual-Computing-Lab/openpose) pose 
detection inside a Jupyter Notebook. You will need to install Docker and Docker Compose before running this code.

**Note on hardware**: The docker images are built with the expectation of a CUDA enabled GPU being present on the host.
Code was developed on a machine with an NVIDIA RTX 2080ti. The code might still work with CPU only, but I have
not tested this.

# Quickstart

From the project root dir, run:

```bash
# Note: Depending on your Docker Compose version, you may need to run 'docker-compose' instead of 'docker compose'
docker network create openpose_net
docker compose up   # Add the -d flag if you want to run in detached mode
```

**Alternatively**, if you want to make modifications and build the images from the local dockerfiles, use:
```bash
# Note: Depending on your Docker Compose version, you may need to run 'docker-compose' instead of 'docker compose'
docker compose -f docker-compose.build.yaml up --build   # Add the -d flag if you want to run in detached mode
```

You should now be able to visit [http://localhost:8888/lab](http://localhost:8888/lab/) in your browser and find the
Jupyter server running there. The default password for the server is ```openpose```. You can change this by following
the [instructions here](https://stackoverflow.com/questions/66063686/set-jupyter-lab-password-encrypted-with-sha-256), 
updating the ```jupyter_notebook_config.json``` file with your hashed password, and rebuilding the image.

![Alt text](/docs/openpose_jupyter.png?raw=true "OpenPose Jupyter")

To stop the running containers:

```bash
docker compose down
```
