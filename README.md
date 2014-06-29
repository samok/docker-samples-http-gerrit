Docker + Gerrit
===============

This will run Gerrit behind HTTP simple auth using Apache2.

How to use this...
==================

Clone the repository
--------------------

```bash
$ git clone https://github.com/jgeewax/docker-gerrit.git
```

Configure things for your environment
-------------------------------------

1. Edit your gerrit configuration files in the `gerrit` directory.
   Anything in this directory will be copied over at build time.

2. Edit your apache configuration files in the `apache` directory.
   htpasswd and gerrit.conf will be moved into `/etc/apache2`.

Note: Your git repositories will be stored in `git/` (which is mounted as
a writable volume on the container.

Build the image
---------------------

```bash
$ docker build -t <username>/gerrit .
```

Run the container as a daemon
-----------------------------

```bash
$ ./run-daemon
```
