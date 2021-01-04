FROM ruby:2.5.5-stretch
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev

# Install Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get install -y nodejs
RUN apt-get update && apt-get install -y yarn

RUN mkdir /shivyog
WORKDIR /shivyog
COPY Gemfile /shivyog/Gemfile
COPY Gemfile.lock /shivyog/Gemfile.lock
COPY engines /shivyog/engines
RUN bundle install
COPY . /shivyog
RUN yarn install
