FROM node:12.14-alpine

ENV NODE_ENV=production
ENV HOST 0.0.0.0

RUN mkdir /frontend
COPY ./frontend /frontend
WORKDIR /frontend

EXPOSE 3000

RUN yarn install
RUN yarn build

CMD ["yarn", "start"]
