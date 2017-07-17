FROM ruby:2.4

ADD . /srv/bestgems.org

WORKDIR /srv/bestgems.org

RUN bundle install

CMD rackup -o 0.0.0.0
