FROM ruby:3.2.3-alpine

RUN apk add --no-cache git build-base curl-dev gcompat tzdata

ENV BUNDLE_CACHE=/tmp/bundle \
    BUNDLE_JOBS=2 \
    PORT=3000

WORKDIR /rails
COPY Gemfile Gemfile.lock ./

# Runs bundle install with a cache volume to speed up builds
RUN --mount=type=cache,id=gems,target=/tmp/bundle \
    bundle install

COPY bin ./bin/

# ENTRYPOINT ["/rails/bin/docker-entrypoint"]
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
