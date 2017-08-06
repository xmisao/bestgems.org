FROM ruby:2.4

ADD . /srv/bestgems.org

WORKDIR /srv/bestgems.org

RUN bundle install --path .bundle

CMD bundle exec rackup -o 0.0.0.0
