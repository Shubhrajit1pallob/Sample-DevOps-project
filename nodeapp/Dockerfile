FROM node:18-alpine

WORKDIR /usr/app

COPY package*.json ./

RUN npm install && npm audit fix --force

COPY . .

EXPOSE 3000

CMD ["node", "server.js"]

