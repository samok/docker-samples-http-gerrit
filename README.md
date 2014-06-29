Docker + Gerrit
===============

This will run Gerrit behind HTTP simple auth using Apache2.

Configuration
=============

There are three volumes that need to be mounted for this image:

1. `gerrit/` (read only)
   
    This volume holds your gerrit configuration files (hooks, etc, plugins, ...).

2. `apache/` (read only)

   This volume holds your apache2 configuration files (htpasswd, gerrit.conf).

3. `git/`

   This volume holds your git repositories (All-Projects.git, etc)

Update all the configuration files (add any other files you want) and you
should be good to go.

Running as a daemon
===================

```bash
./run-daemon
```

Building from scratch
=====================

```bash
git clone https://github.com/jgeewax/docker-gerrit.git
cd docker-gerrit
docker build -t jgeewax/gerrit .
```
