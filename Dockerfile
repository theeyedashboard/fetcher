FROM node
RUN npm install express
RUN npm install request
RUN npm install cheerio
RUN npm install xml2js 
RUN npm install -g coffee-script
RUN npm install -g nodemon
RUN mkdir /fetcher
COPY services /fetcher/
COPY main.coffee /fetcher/
WORKDIR /fetcher
CMD ["nodemon", "main.coffee"]
