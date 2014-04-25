## Compiling new versions of stunnel using Docker

Install [docker](https://www.docker.io/). For OSX, I recommend using
[dvm](http://fnichol.github.io/dvm/) to get virtualbox, vagrant and boot2docker
set up correctly.

Build:

```
$ cd support
$ docker build -t your-username/stunnel-builder .
$ docker run -i -v /home/docker/cache:/var/cache \
  -e STUNNEL_VERSION=<stunnel-version> \
  -e AWS_ACCESS_KEY_ID=<ur-key> \
  -e AWS_SECRET_ACCESS_KEY=<ur-secret-key> \
  -e S3_BUCKET="<ur-bucket-name>" \
  your-username/stunnel-builder
```

## Publishing buildpack updates

```
heroku plugins:install https://github.com/heroku/heroku-buildpacks

cd heroku-buildpack-stunnel
git checkout master
heroku buildpacks:publish <ur-user-name>/stunnel
```
