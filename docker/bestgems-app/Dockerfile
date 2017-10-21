FROM ruby:2.4

ADD . /srv/bestgems.org
ADD docker/bin/wait-for-it.sh /bin

WORKDIR /srv/bestgems.org

RUN apt-get update && apt-get -y install libleveldb-dev && apt-get clean

RUN bundle install --path .bundle

CMD bundle exec rackup -o 0.0.0.0
