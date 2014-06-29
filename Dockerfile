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
#ENV GERRIT_CONFIG $GERRIT_ROOT/etc/gerrit.config
#ENV GERRIT_SECURE_CONFIG $GERRIT_ROOT/etc/secure.config

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

# Copy over all sorts of root-owned files.
RUN ln -s /gerrit/htpasswd $GERRIT_HOME/htpasswd

ADD http://gerrit-releases.storage.googleapis.com/gerrit-2.7.war $GERRIT_WAR

RUN rm /etc/apache2/sites-enabled/*
RUN ln -s /gerrit/000-gerrit.conf /etc/apache2/sites-enabled/

RUN echo "ServerName localhost" | tee /etc/apache2/conf-available/fqdn.conf
RUN sudo ln -s /etc/apache2/conf-available/fqdn.conf /etc/apache2/conf-enabled/fqdn.conf

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Make sure gerrit owns all of his stuff.
RUN chown -R ${GERRIT_USER}:${GERRIT_USER} $GERRIT_HOME

# Configure gerrit.
USER gerrit
RUN java -jar $GERRIT_WAR init --batch -d $GERRIT_ROOT --no-auto-start

# Jump back to root.
USER root

# Add the config file overtop of whatever is generated (and fix ownership).
RUN rm -rf $GERRIT_ROOT/etc $GERRIT_ROOT/hooks $GERRIT_ROOT/plugins $GERRIT_ROOT/static
RUN ln -sf /gerrit/etc $GERRIT_ROOT/etc
RUN ln -sf /gerrit/hooks $GERRIT_ROOT/hooks
RUN ln -sf /gerrit/plugins $GERRIT_ROOT/plugins
RUN ln -sf /gerrit/static $GERRIT_ROOT/static
RUN ln -sf /git $GERRIT_ROOT/git
RUN ln -s /usr/share/java/mysql.jar /home/gerrit/gerrit/lib/mysql.jar

RUN chown -R ${GERRIT_USER}:${GERRIT_USER} $GERRIT_HOME

# Expose ports and start everything.
EXPOSE 80 29418
CMD ["/usr/sbin/service", "supervisor", "start"]
