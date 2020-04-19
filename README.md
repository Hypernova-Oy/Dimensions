# Dimensions

   * [Dimensions](#dimensions)
      * [About](#about)
      * [Requirements](#requirements)
      * [Installation](#installation)
      * [Configuration](#configuration)
      * [Testing installation](#testing-installation)
      * [Running application](#running-application)
      * [License](#license)

## About

This Mojolicious application maintains your business product and user dimensions.
It's a poor man's private accounting tool. It is recommended to generate a parser
script to import each item in your general ledger report into Dimensions database
- or if your accountant provides you a csv simply import all the lines.

Then, you will be able to define dimensions for each item in your general ledger
report. It supports product and user dimensions.

This app then calculates the incomes and expenses of each product and reports
you the totals for each product and user.

**This is not an official accounting tool!** It does not generate reports that
your tax authority will accept. This app is simply for private insight.

## Requirements

``
apt install make gcc cpanminus
``

## Installation

```
git clone git@github.com:Hypernova-Oy/Dimensions.git
cd Dimensions/
sudo cpanm --installdeps .
```

* Install database
```
mysql database_name < data/schema.sql
mysql database_name < data/permissions.sql
```
* Grant all privileges to the database user

## Configuration

```
cp hypernova-dimensions.conf.tmpl hypernova-dimensions.conf
```

* Edit `hypernova-dimensions.conf` and add your database credentials.

## Testing installation

```
prove -r t
```

## Running application

```
hypnotoad script/hypernova_dimensions -f
```

## License

See [LICENSE](LICENSE)
