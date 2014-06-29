# Gerrit + Apache
#
# VERSION  0.2

FROM  ubuntu:14.04

MAINTAINER JJ Geewax <jj@geewax.org>

# Apache environment variables.
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_RUN_GROUP www-data
ENV APACHE_RUN_USER www-data

# Gerrit environment variables.
ENV GERRIT_USER gerrit
ENV GERRIT_HOME /home/gerrit
ENV GERRIT_ROOT $GERRIT_HOME/gerrit
ENV GERRIT_WAR $GERRIT_HOME/gerrit.war

# Supervisor environment variables.
ENV SUPERVISOR_LOG_DIR /var/log/supervisor

# Deal with packages and modules.
RUN apt-get update
RUN apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-6-jre supervisor git apache2 libmysql-java vim
RUN a2enmod rewrite proxy proxy_http

# Create users and directories
RUN useradd -m $GERRIT_USER
RUN mkdir -p $GERRIT_ROOT
RUN mkdir -p $SUPERVISOR_LOG_DIR
RUN mkdir -p /var/lock/apache2

# Pull down the gerrit package.
ADD http://gerrit-releases.storage.googleapis.com/gerrit-2.7.war $GERRIT_WAR

# Configure Apache.
RUN rm /etc/apache2/sites-enabled/*
ADD apache/htpasswd /etc/apache2/htpasswd
ADD apache/gerrit.conf /etc/apache2/sites-available/gerrit.conf
RUN ln -s /etc/apache2/sites-available/gerrit.conf /etc/apache2/sites-enabled/000-gerrit.conf
RUN echo "ServerName localhost" | tee /etc/apache2/conf-available/fqdn.conf
RUN sudo ln -s /etc/apache2/conf-available/fqdn.conf /etc/apache2/conf-enabled/fqdn.conf

# Configure supervisor.
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Make sure gerrit owns all of his stuff.
RUN chown -R ${GERRIT_USER}:${GERRIT_USER} $GERRIT_HOME

# Configure gerrit (as gerrit).
USER gerrit
RUN java -jar $GERRIT_WAR init --batch -d $GERRIT_ROOT --no-auto-start

# Jump back to root.
USER root

# Add the config file overtop of whatever is generated (and fix ownership).
ADD gerrit/ /tmp/gerrit
RUN cp -R /tmp/gerrit/* $GERRIT_ROOT
RUN ln -sf /git $GERRIT_ROOT/git
RUN ln -s /usr/share/java/mysql.jar /home/gerrit/gerrit/lib/mysql.jar

RUN chown -R ${GERRIT_USER}:${GERRIT_USER} $GERRIT_HOME

# Expose ports and start everything.
EXPOSE 80 29418 8080
CMD ["/usr/sbin/service", "supervisor", "start"]
