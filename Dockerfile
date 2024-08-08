FROM node:16-alpine as node
ENV NODE_OPTIONS=--openssl-legacy-provider

FROM ruby:3.3.1
ENV LANG C.UTF-8
ENV TZ Asia/Tokyo

RUN apt-get update && apt-get install -y build-essential libpq-dev ca-certificates curl gnupg \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && NODE_MAJOR=18 \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update -qq \
    && apt-get install -y nodejs yarn \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /recipi_ai_assistant
WORKDIR /recipi_ai_assistant

RUN gem install bundler

COPY Gemfile /recipi_ai_assistant/Gemfile
COPY Gemfile.lock /recipi_ai_assistant/Gemfile.lock
COPY yarn.lock /recipi_ai_assistant/yarn.lock

RUN bundle install
RUN yarn install

COPY . /recipi_ai_assistant

CMD ["rails", "server", "-b", "0.0.0.0"]

