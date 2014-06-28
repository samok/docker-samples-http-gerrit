# gerrit
#
# VERSION               0.2

FROM  ubuntu

MAINTAINER JJ Geewax <jj@geewax.org>

# Environment variables.
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV GERRIT_HOME /home/gerrit/gerrit
ENV GERRIT_USER gerrit
ENV GERRIT_WAR /home/gerrit/gerrit.war
ENV GERRIT_CONFIG /home/gerrit/gerrit/etc/gerrit.confg
ENV SUPERVISOR_LOG_DIR /var/log/supervisor

# Deal with packages.
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update
RUN apt-get upgrade
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-6-jre-headless sudo git-core supervisor vim-tiny apache2

# Create users and directories
RUN useradd -m $GERRIT_USER
RUN mkdir -p $GERRIT_HOME
RUN chown ${GERRIT_USER}.${GERRIT_USER} $GERRIT_HOME
RUN chown -R ${GERRIT_USER}.${GERRIT_USER} $GERRIT_HOME
RUN mkdir -p $SUPERVISOR_LOG_DIR

# Copy over the supervisor config.
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Get gerrit set up properly.
USER gerrit
ADD http://gerrit-releases.storage.googleapis.com/gerrit-2.7.war $GERRIT_WAR
ADD gerrit.config $GERRIT_CONFIG
RUN java -jar $GERRIT_WAR init --batch -d $GERRIT_HOME

# Get apache is set up properly.
USER www-data
ADD 001-gerrit.conf /etc/apache2/sites-available/
RUN ln -s /etc/apache2/sites-available/001-gerrit.conf /etc/apache2/sites-enabled/

# Expose ports, start everything.
USER root
EXPOSE 80 8080 29418
CMD ["/usr/sbin/service","supervisor","start"]
# CMD ["/usr/sbin/apache2" "-D", "FOREGROUND"]
