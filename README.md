Heroku buildpack: stunnel
=========================

This is a [Heroku buildpack](http://devcenter.heroku.com/articles/buildpacks) that
allows one to run stunnel in a dyno alongside application code.
It is meant to be used in conjunction with other buildpacks as part of a
[multi-buildpack](https://github.com/ddollar/heroku-buildpack-multi).

The current use of this buildpack is to allow for secure connection to Redis
databases.

It uses [stunnel](http://stunnel.org/) and was extracted from the
[pgbouncer](https://github.com/gregburek/heroku-buildpack-pgbouncer) buildpack.


Usage
-----

Example usage:

    $ ls -a
    .buildpacks  Gemfile  Gemfile.lock  Procfile  config/  config.ru

    $ heroku config:add BUILDPACK_URL=https://github.com/ddollar/heroku-buildpack-multi.git

    $ cat .buildpacks
    https://github.com/yesware/heroku-buildpack-stunnel.git
    https://github.com/heroku/heroku-buildpack-ruby.git

    $ cat Procfile
    web:    bin/start-stunnel bundle exec unicorn -p $PORT -c ./config/unicorn.rb -E $RACK_ENV
    worker: bundle exec rake worker

    $ git push heroku master
    ...
    -----> Fetching custom git buildpack... done
    -----> Multipack app detected
    =====> Downloading Buildpack: https://github.com/yesware/heroku-buildpack-stunnel.git
    =====> Detected Framework: stunnel
           Using stunnel version: 5.01
    -----> Fetching and vendoring stunnel into slug
    -----> Moving the configuration generation script into app/bin
    -----> Moving the start-stunnel script into app/bin
    -----> stunnel done
    =====> Downloading Buildpack: https://github.com/heroku/heroku-buildpack-ruby.git
    =====> Detected Framework: Ruby
    -----> Compiling Ruby/Rails
    -----> Using Ruby version: ruby-2.0.0
    -----> Installing dependencies using 1.5.2
    ...

The buildpack will install and configure stunnel to connect to the
`STUNNEL_URLS` over a SSL connection. Prepend `bin/start-stunnel`
to any process in the Procfile to run stunnel alongside that process.


Settings
-----
Some settings are configurable through app config vars at runtime. Refer to the appropriate documentation for
[stunnel](http://linux.die.net/man/8/stunnel) configurations to see what settings are right for you.

- `STUNNEL_URLS` REQUIRED. List of ENV variables to be tunneled, more detail below.
- `STUNNEL_PEM` REQUIRED. Stunnel client certificate.


Multiple Databases
----
It is possible to connect to multiple databases through stunnel by setting
`STUNNEL_URLS` to a list of config vars. Example:

    $ heroku config:add STUNNEL_URLS="REDIS_APP_URL REDIS_ALTERNATE_URL"
    $ heroku run bash

    ~ $ env | grep 'REDIS_APP_URL REDIS_ALTERNATE_URL'
    REDIS_APP_URL=redis://username:password@ec2-107-20-228-134.compute-1.amazonaws.com:6379/0
    REDIS_ALTERNATE_URL=redis://username:password@ec2-50-19-210-113.compute-1.amazonaws.com:6379/0

    ~ $ bin/start-stunnel env # filtered for brevity
    REDIS_APP_URL_STUNNEL=redis://username:password@127.0.0.1:6001/0
    REDIS_ALTERNATE_URL_STUNNEL=redis://username:password@127.0.0.1:6002/0


For more info, see [CONTRIBUTING.md](CONTRIBUTING.md)
