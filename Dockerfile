FROM ruby:2.7.5-alpine3.15
MAINTAINER pysga1996
WORKDIR /opt/zap-delivery-service
RUN apk update && apk add --update --no-cache \
     linux-headers \
     libpq-dev \
     busybox-extras \
     build-base
COPY Gemfile .
# cached
RUN gem install racc -v '1.6.2' && gem install pg -v '1.2.3' --source 'https://rubygems.org/'
RUN bundle install
COPY . .
ENTRYPOINT ["bundle", "exec"]
CMD ["rdebug-ide", "--skip_wait_for_start", "--host=0.0.0.0", "--port=3001", " -- ", "bin/rails s -p 3000 -b 0.0.0.0"]
EXPOSE 3000 3001