FROM node:7.0
RUN apt-get update
RUN apt-get install -y python-pip
RUN pip install xlrd

# Set the locale
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y locales
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    echo 'LANG="en_US.UTF-8"'>/etc/default/locale && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

ENV LANG en_US.UTF-8

# INSTALL GLOBAL NODE DEPENDENCIES
RUN npm install -g coffee-script nodemon

# INSTALL LOCAL NODE DEPENDENCIES
COPY package.json /tmp/package.json
RUN cd /tmp && npm install
RUN mkdir -p /fetcher/src && cp -a /tmp/node_modules /fetcher/

# PATCH XML-PARSER
WORKDIR /fetcher
COPY scripts /fetcher/scripts
WORKDIR /fetcher/scripts
RUN ./patch_excel_parser.sh

# COPY APP
COPY src /fetcher/src

# RUN APP
WORKDIR /fetcher
# CMD ["sleep", "10000"]
# CMD ["npm", "test"]
CMD ["npm", "start"]
