FROM ruby:2.7.5
MAINTAINER pysga1996

WORKDIR /webroot

ADD . /webroot/
#RUN gem install
RUN bundle install

EXPOSE 3000 1234 26162
VOLUME /webroot
#CMD ["puma"]
CMD ["rdebug-ide --host 0.0.0.0 --port 1234 --dispatcher-port 26162 -- bin/rails s -p 3000 -b 0.0.0.0"]