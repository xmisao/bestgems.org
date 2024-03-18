FROM public.ecr.aws/docker/library/ruby:3.3.0 as leveldb-builder
WORKDIR /build
RUN wget https://github.com/google/leveldb/archive/refs/tags/v1.18.tar.gz && \
    tar -zxvf v1.18.tar.gz && \
    cd leveldb-1.18 && \
    make

FROM public.ecr.aws/docker/library/ruby:3.3.0
ADD docker/bin/wait-for-it.sh /bin
COPY --from=leveldb-builder /build/leveldb-1.18/include/leveldb /usr/local/include/leveldb
COPY --from=leveldb-builder /build/leveldb-1.18/libleveldb.so* /usr/local/lib/
COPY --from=leveldb-builder /build/leveldb-1.18/libleveldb.a /usr/local/lib/
RUN ldconfig
WORKDIR /app
COPY Gemfile Gemfile.lock /app/
RUN bundle install
COPY . /app
CMD bundle exec rackup -o 0.0.0.0
