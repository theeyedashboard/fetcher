FROM node
RUN npm install express
RUN mkdir /fetcher
COPY services /fetcher/
COPY fetcher.js /fetcher/
CMD ["node", "/fetcher/fetcher.js"]
