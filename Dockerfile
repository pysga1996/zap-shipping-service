FROM ruby:2.7.5
MAINTAINER pysga1996
WORKDIR /webroot
COPY Gemfile Gemfile.lock /webroot/
# cached
RUN bundle install
COPY . /webroot/
#CMD ["puma"]
ENTRYPOINT ["rdebug-ide", "--host=0.0.0.0", "--port=3001", " -- ", "bin/rails s -p 3000 -b 0.0.0.0"]
EXPOSE 3000 3001