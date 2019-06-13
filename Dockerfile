FROM ruby:2.6.3

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

ARG BUNDLER_VERSION=2.0.1
RUN gem install bundler:$BUNDLER_VERSION

COPY Gemfile .
COPY Gemfile.lock .
ARG BUNDLE_WITHOUT=test
RUN bundle install --without ${BUNDLE_WITHOUT} --deployment

COPY . .
ARG BUILD_ENV=development
ENV RAILS_ENV $BUILD_ENV
ARG RAILS_MASTER_KEY
ENV RAILS_MASTER_KEY $RAILS_MASTER_KEY
RUN bundle exec rake assets:precompile

ENV RAILS_LOG_TO_STDOUT=true RAILS_SERVE_STATIC_FILES=true
ENV HOST 0.0.0.0
ENV PORT 3000
EXPOSE $PORT

CMD ["bundle", "exec", "rails server"]
