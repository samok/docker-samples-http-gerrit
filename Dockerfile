# Gerrit + Apache
#
# VERSION  0.2

FROM  ubuntu:14.04

MAINTAINER JJ Geewax <jj@geewax.org>

# Environment variables.
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_RUN_GROUP www-data
ENV APACHE_RUN_USER www-data

ENV GERRIT_USER gerrit
ENV GERRIT_HOME /home/gerrit
ENV GERRIT_ROOT $GERRIT_HOME/gerrit
ENV GERRIT_WAR $GERRIT_HOME/gerrit.war
ENV GERRIT_CONFIG $GERRIT_ROOT/etc/gerrit.confg

ENV SUPERVISOR_LOG_DIR /var/log/supervisor

# Deal with packages.
RUN apt-get update
RUN apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-6-jre supervisor vim apache2

# Create users and directories
RUN useradd -m $GERRIT_USER
RUN mkdir -p $GERRIT_ROOT
RUN chown -R ${GERRIT_USER}:${GERRIT_USER} $GERRIT_HOME
RUN mkdir -p $SUPERVISOR_LOG_DIR

# Copy over all sorts of root-owned files.
ADD 001-gerrit.conf /etc/apache2/sites-available/
RUN ln -s /etc/apache2/sites-available/001-gerrit.conf /etc/apache2/sites-enabled/
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Configure gerrit..
USER gerrit
ADD htpasswd $GERRIT_HOME/htpasswd
ADD http://gerrit-releases.storage.googleapis.com/gerrit-2.7.war $GERRIT_WAR
RUN java -jar $GERRIT_WAR init --batch -d $GERRIT_ROOT
ADD gerrit.config $GERRIT_CONFIG  # Add the config overtop of whatever is generated.

# Expose ports, start everything.
USER root
EXPOSE 80 29418
CMD ["/usr/sbin/service", "supervisor", "start"]
