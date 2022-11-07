FROM cschranz/gpu-jupyter:v1.4_cuda-10.1_ubuntu-18.04_python-only
FROM dcbark01/openpose_backend:latest

USER root
# Install all OS dependencies for notebook server that starts but lacks all
# features (e.g., download as all possible file formats)
ENV DEBIAN_FRONTEND noninteractive
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A4B469963BF863CC && \
 apt-get update && apt-get -yq dist-upgrade \
 && apt-get install -yq --no-install-recommends \
    wget \
    bzip2 \
    ca-certificates \
    sudo \
    locales \
    fonts-liberation \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

COPY --from=0 /usr/local/bin/start.sh /usr/local/bin/start.sh
COPY --from=0 /usr/local/bin/start-notebook.sh /usr/local/bin/start-notebook.sh
COPY --from=0 /usr/local/bin/start-singleuser.sh /usr/local/bin/start-singleuser.sh
COPY --from=0 /usr/local/bin/fix-permissions /usr/local/bin/fix-permissions

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

# Install Tini
RUN wget --quiet https://github.com/krallin/tini/releases/download/v0.10.0/tini && \
    echo "1361527f39190a7338a0b434bd8c88ff7233ce7b9a4876f3315c22fce7eca1b0 *tini" | sha256sum -c - && \
    mv tini /usr/local/bin/tini && \
    chmod +x /usr/local/bin/tini

# Configure environment
ENV CONDA_DIR=/usr/bin/python3.6 \
    SHELL=/bin/bash \
    NB_USER=jovyan \
    NB_UID=1000 \
    NB_GID=100 \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8
ENV PATH=$CONDA_DIR/bin:$PATH \
    HOME=/home/$NB_USER


# Copy config file
# The config file can be updated by entering the container and running start-notebook.sh password --generate-config --config jupyter_notebook_config.json
COPY jupyter_notebook_config.json /home/jovyan/.jupyter/jupyter_notebook_config.json

# Create jovyan user with UID=1000 and in the 'users' group
# and make sure these dirs are writable by the `users` group.
RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    chown $NB_USER:$NB_GID $CONDA_DIR && \
    chmod g+w /etc/passwd /etc/group && \
    fix-permissions $HOME && \
    fix-permissions $CONDA_DIR

USER $NB_UID

# Setup work directory for backward-compatibility
RUN mkdir /home/$NB_USER/work && \
    fix-permissions /home/$NB_USER


ENV PATH=$PATH:~/.local/bin
RUN pip3 install --upgrade pip && \
  pip3 install jupyter jupyterhub jupyterlab ipywidgets matplotlib


USER root
EXPOSE 8888
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1 \
    && update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1


# Copy source files (notebooks + modules)
# Change user to make files r/w
USER $NB_UID
COPY src /home/jovyan/image

# Copy README to root
RUN cp /home/jovyan/image/README.ipynb /home/jovyan

# Set workdir
WORKDIR /home/jovyan

# Start command
ENTRYPOINT ["tini", "--"]
CMD ["start-notebook.sh"]
