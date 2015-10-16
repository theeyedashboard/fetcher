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
RUN mkdir /fetcher
COPY services /fetcher/services
COPY main.coffee /fetcher/
COPY fetcher.coffee /fetcher/
COPY start.sh /fetcher/
WORKDIR /fetcher
CMD /fetcher/start.sh
