FROM node
RUN apt-get update
RUN apt-get install -y python-pip
RUN pip install xlrd
RUN npm install express
RUN npm install request
RUN npm install cheerio
RUN npm install xml2js
RUN npm install excel-parser
RUN npm install moment --save
RUN npm install url
RUN npm install -g coffee-script
RUN npm install -g nodemon

# Set the locale
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y locales
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    echo 'LANG="en_US.UTF-8"'>/etc/default/locale && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

ENV LANG en_US.UTF-8

# RUN apt-get install locales
# RUN locale-gen en_US.UTF-8
# ENV LANG en_US.UTF-8
# ENV LANGUAGE en_US:en
# ENV LC_ALL en_US.UTF-8

RUN mkdir /fetcher
COPY services /fetcher/services
COPY main.coffee /fetcher/
COPY fetcher.coffee /fetcher/
COPY start.sh /fetcher/
WORKDIR /fetcher
CMD /fetcher/start.sh
