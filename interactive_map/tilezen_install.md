_Adapted from the [vector-datasource wiki](https://github.com/tilezen/vector-datasource/wiki/Mapzen-Vector-Tile-Service)_

Mapzen Vector Tiles
===================

See info about the hosted version of this service here:

[Mapzen Vector Tile Service](https://github.com/tilezen/vector-datasource)

Installation Guide
------------------
Tested on an Ubuntu 16.04 operating system.

### 1. Install

#### Install dependencies

```shell
# install misc tools
sudo apt-get install git unzip python-yaml
# install postgres / postgis
sudo apt-get install postgresql postgresql-contrib postgis postgresql-9.5-postgis-2.2
# Install jinja2
sudo apt-get install python-jinja2
# install tilezen fork of osm2pgsql
sudo apt-add-repository ppa:tilezen
sudo apt-get update
sudo apt-get install osm2pgsql
```

#### NOTE: postgresql 9.5+ is required, only Python 2.7.x is supported

### 2. Prepare data

#### Download mapzen/vector-datasource:

This repo contains the supplementary data to load (if you want) and the queries that are issued to the database for each layer (important).

```shell
git clone https://github.com/mapzen/vector-datasource.git
cd vector-datasource
# now checkout the latest tagged release (see warning below), for example:
# git checkout v1.4.0
```

**WARNING:** If you are standing up your own instance of the Tilezen stack (rather than doing development), it's best practice to checkout the [latest tagged release](https://github.com/mapzen/vector-datasource/releases) rather than running off `master`. At the time of this writing that is `v1.4.0`, so you'd `git checkout v1.4.0` to be on the same code base as the production Mapzen Vector Tile service. Similarly, you'd need to pin yourself against the related project's versions, e.g.: `Requires: tileserver v2.1.0 and tilequeue v1.8.0 and mapbox-vector-tile v1.2.0` mentioned in the release notes in the sections below.

#### Load additional data and update database

The `vector-datasource/data` directory contains scripts to [load additional data](https://github.com/tilezen/vector-datasource/wiki/Mapzen-Vector-Tile-Service#2-load-data) and update the database to match our expected schema. 

#### Add extra info
We ran the contents of [`update_streets.sql`](update_streets.sql) to do the following:
1. Create a new table `gis.streets_zoomlevels` specifying zoom levels based on the functional codes of **streets** (`fcode_desc`). This implicitly excludes non-streets from the final tiling.
2. Create a view joining `gis.street_centreline` with `gis.streets_zoomlevels` 

I determined the zoom levels by playing around with [this handy map](http://leafletjs.com/examples/zoom-levels/example-delta.html) 

### 3. Serve vector tiles

#### Install dependencies

```shell
# dev packages for building
sudo apt-get install build-essential autoconf libtool pkg-config
# dev packages for python and dependencies
sudo apt-get install python-dev python-virtualenv libgeos-dev libpq-dev python-pip python-pil libxml2-dev libxslt-dev
```

#### Download Tileserver

```shell
git clone https://github.com/mapzen/tileserver.git
git checkout v2.1.0
```

#### Prepare a virtualenv
At the moment, only `Python 2.7.x` [is supported](https://github.com/tilezen/tileserver/issues/49), so make sure you have a Python 2.7 version installed 
```shell
# Create a virtualenv called 'env'. This can be named anything, and can be in the tileserver directory or anywhere on your system.
virtualenv env --python python2.7
source env/bin/activate
```

#### Install Python dependencies

Install dependencies for tileserver

```shell
pip install -U -r tileserver/requirements.txt
(cd tileserver && python setup.py develop)
# optionally checkout the latest tagged release instead (see warning above), for example:
```

Install tilequeue in development mode

```shell
git clone https://github.com/tilezen/tilequeue.git
(cd tilequeue && python setup.py develop)
# optionally checkout the latest tagged release instead (see warning above), for example:
# git checkout v1.8.0
```

Finally, there's some code in `vector-datasource` as well, which needs to be installed.

```shell
(cd vector-datasource && python setup.py develop)
```

#### Configure

```shell
cd ../tileserver
cp config.yaml.sample config.yaml
# update configuration as necessary
edit config.yaml
```
**Make sure `dbnames` are an array**, e.g.:
```yaml
dbnames: [bigdata]
```

#### Run

```shell
python tileserver/__init__.py config.yaml
```

#### Contribute!

You're ready to help us improve the Tilezen project! Please read our [CONTRIBUTING.md](https://github.com/tilezen/vector-datasource/blob/master/CONTRIBUTING.md) document to understand how to contribute code.

#### Tests 

Need to confirm your configuration? A [test suite](https://github.com/mapzen/vector-datasource/blob/master/TESTS.md) is included which can be run against a tile server. 

##### Sample test URLs

* http://localhost:8080/roads/16/19293/24641.mvt
* http://localhost:8080/all/16/19293/24641.json

