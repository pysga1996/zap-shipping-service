FROM ruby:2.7.5
MAINTAINER pysga1996

WORKDIR /webroot

COPY Gemfile Gemfile.lock /webroot/

RUN bundle install

COPY . /webroot/

CMD ["puma"]
#ENTRYPOINT ["rdebug-ide", "--host=0.0.0.0", "--port=1234", " -- ", "bin/rails s -p 3000 -b 0.0.0.0"]

VOLUME /webroot
EXPOSE 3000 1234