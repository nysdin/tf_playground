FROM node:18.12.1-alpine as node

FROM ruby:3.1.2-alpine

WORKDIR /tf_playground

ARG RAILS_ENV=production
ARG NODE_ENV=production

COPY .ruby-version Gemfile Gemfile.lock ./
RUN apk --update-cache add --no-cache --virtual .ruby-builddeps curl-dev make gcc libc-dev g++ git linux-headers && \
  apk --update-cache add --no-cache tzdata mariadb-dev pkgconfig imagemagick imagemagick-dev imagemagick-libs curl

RUN gem install bundler -v '2.3.7' --no-document && \
  gem cleanup bundler && \
  bundle config set force_ruby_platform true && \
  bundle install && \
  apk del --purge .ruby-builddeps

# node setup
COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/include/node /usr/local/include/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node /opt/yarn-v1.22.19 /opt/yarn
COPY yarn.lock package.json webpack.config.js ./
RUN ln -s /usr/local/bin/node /usr/local/bin/nodejs && \
    ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm && \
    ln -s /opt/yarn/bin/yarn  /usr/local/bin/yarn && \
    yarn install && \
    yarn cache clean

COPY bin bin
COPY config config
COPY app app
COPY lib lib
COPY db db
COPY public public
COPY config.ru ./

RUN mkdir log && \
    mkdir tmp && \
    mkdir tmp/sockets && \
    mkdir tmp/pids && \
    yarn run build && \
    rm -rf node_modules tmp/cache

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
