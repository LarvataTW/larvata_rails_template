# See https://github.com/phusion/passenger-docker/blob/master/Changelog.md
FROM phusion/passenger-ruby23:0.9.19

RUN apt-get update && \
    apt-get install -y libpng12-dev libglib2.0-dev zlib1g-dev libbz2-dev libtiff4-dev libjpeg8-dev imagemagick

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# Run Bundle in a cache efficient way
COPY Gemfile* /tmp/
WORKDIR /tmp
RUN bundle install

# Add the nginx info
ADD nginx.conf /etc/nginx/sites-enabled/webapp.conf
ADD rails.env.conf /etc/nginx/main.d/rails.env.conf

# Remove the default site
RUN rm /etc/nginx/sites-enabled/default

# Start Nginx / Passenger
RUN rm -f /etc/service/nginx/down

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
