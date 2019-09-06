FROM node:12.9.1-stretch as build

WORKDIR /app

# Install dependecies
COPY .npmrc .
COPY package.json .
COPY package-lock.json .
RUN npm ci

COPY . .

RUN npm run build
RUN npm pack
