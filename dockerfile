# Build nodejs
FROM node:latest AS node_stage
# Set working directory in the container
WORKDIR /temp
# Copy files from the Node.js image
RUN mkdir /temp/node_files
RUN cp -R /usr/local/bin /temp/node_files/bin
RUN cp -R /usr/local/lib /temp/node_files/lib

# Build Container
FROM lscr.io/linuxserver/rdesktop:ubuntu-xfce
# Copy files from the Node.js stage
COPY --from=node_stage /temp/node_files /usr/local/
COPY --from=golang:latest /usr/local/go /usr/local/go

# Install golang
ENV PATH=$PATH:/usr/local/go/bin
ENV PATH=$PATH:/root/go/bin

# Install deps
RUN apt-get update && apt-get install -y \
    git \
    npm \ 
    javascriptcoregtk-4.1-dev \
    libwebkit2gtk-4.0-dev \
    libgtk-3-dev \
    vim \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /home

# Install Wails
RUN git clone https://github.com/wailsapp/wails 
RUN cd wails && git checkout v3-alpha
RUN cd wails/v3/cmd/wails3 && go install

RUN echo 'export GOPATH=$HOME/go \n export PATH=$PATH:$GOPATH/bin \n export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc

# RDP Port
EXPOSE 3389
