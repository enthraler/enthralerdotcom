# latest official node image
FROM node:latest
ADD . /var/www/html
RUN yarn global add supervisor
RUN cd /var/www/html && yarn
WORKDIR /var/www/html
EXPOSE 3000
CMD ["supervisor", "-w", "server.js", "--", "server.js"];