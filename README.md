# BestGems.org

Ruby gems downloads ranking site.

Hosted on [http://bestgems.org/](http://bestgems.org/).

# For developers

## System requirements

* UNIX like operating system. (Debian or Ubuntu are recommended)
* Ruby 2.4+
* Middleware
  * PostgreSQL 9.6
* Libraries
  * libleveldb-dev
* Docker (Recommended)

### Examples

#### Libraries installation on Debian or Ubuntu

```bash
sudo apt-get install libleveldb-dev
```

#### PostgreSQL installation from Docker

```bash
docker run \
  -d \
  --name bestgems-pg \
  -p 5432:5432 \
  -e POSTGRES_USER=bestgems \
  -e POSTGRES_PASSWORD=bestgems \
  postgres:9.6-alpine
```

## Get the source

Clone this repository.

```bash
git clone git@github.com:xmisao/bestgems.org.git
cd bestgems.org
```

## Install gems

Execute bundle install.

```bash
bundle install --path vendor/bundle
```

## Configure environment variable

Export environment variables.

```bash
export RACK_ENV=production
export APP_ENV=production
export BESTGEMS_DB_HOST=127.0.0.1
export BESTGEMS_DB_USER=bestgems
export BESTGEMS_DB_PASSWORD=bestgems
export BESTGEMS_DB_NAME=bestgems
export BESTGEMS_LEVELDB_DIR=db/trends
export BESTGEMS_API_KEY=dummy_token
```

## Execute migration

Execute migration.

```bash
bundle exec rake db:migration
```

## Import data

### Step 1. Import dummy data

Import sample data.

```bash
bundle exec rake dev:import_sample
```

### Step 2. Import categories data

Import categories data.

```bash
bundle exec ruby tools/import_categories.rb tools/data/initial_categories.csv
```

### Step 3. Import additional data

#### Start servers

Start servers. The following command starts two processes that the application server and the trend server.

```bash
bin/start
```

##### NOTE:

The application server is BestGems.org main process which is implemented using Sinatra.
Trend server is BestGems.org subprocess which is LevelDB wrapper using dRuby.
BestGems.org requires those processes are running correctly.

#### Import data from RubyGems.org

Import additional data from RubyGems.org. Execute the following on another console.

```bash
bundle exec ruby tools/import_gem_detail.rb http://127.0.0.1:9292/api dummy_token
```

## Finish!

Open `http://localhost:9292/` in your browser.

## Testing

Running test will destroy PostgreSQL data and LevelDB data.
We recommend to prepare isolated environment by following steps.

### Step 1. Configure testing environment variables

```bash
export RACK_ENV=production
export APP_ENV=production
export BESTGEMS_DB_HOST=127.0.0.1
export BESTGEMS_DB_USER=bestgems
export BESTGEMS_DB_PASSWORD=bestgems
export BESTGEMS_DB_NAME=bestgems-test # Important!
export BESTGEMS_LEVELDB_DIR=db/trends-test # Important!
export BESTGEMS_API_KEY=dummy_token
```

### Step 2. Create testing database

```bash
PGPASSWORD=bestgems psql -U bestgems -h 127.0.0.1 -c 'CREATE DATABASE "bestgems-test";'
bundle exec rake db:migration
```

### Step 3. Run test

```bash
bundle exec rake test
```

## Format the source

Format the source by [rufo](https://github.com/ruby-formatter/rufo).

```bash
bundle exec rake format
```

# Build status

[![Build Status](https://travis-ci.org/xmisao/bestgems.org.svg?branch=master)](https://travis-ci.org/xmisao/bestgems.org)
