FROM ruby

ENV S6_OVERLAY_VERSION 1.15.0.0

RUN curl -L https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-amd64.tar.gz -o /tmp/s6-overlay-amd64.tar.gz && \
    tar xzf /tmp/s6-overlay-amd64.tar.gz -C / && \
    rm /tmp/s6-overlay-amd64.tar.gz

ENV NGINX_VERSION 1.9.5-1~jessie

RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62
RUN echo "deb http://nginx.org/packages/mainline/debian/ jessie nginx" >> /etc/apt/sources.list

RUN apt-get update && \
    apt-get install -y ca-certificates nginx=${NGINX_VERSION} && \
    rm -rf /var/lib/apt/lists/* && \
    rm /etc/nginx/conf.d/default.conf
COPY docker/conf/nginx.conf /etc/nginx/nginx.conf

# application user
RUN addgroup --system app && adduser --system --ingroup app --uid 5500 app

# create nginx template file, will be preprcessed by /etc/services.d/nginx/run
COPY docker/conf/app.conf /etc/nginx/conf.d/app.conf.template

COPY docker/conf/services.d/app.sh /etc/services.d/app/run
COPY docker/conf/services.d/finish.sh /etc/services.d/app/finish
COPY docker/conf/services.d/nginx.sh /etc/services.d/nginx/run
COPY docker/conf/services.d/finish.sh /etc/services.d/nginx/finish

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir /app
WORKDIR /app

ENV RACK_ENV production
ENV PORT 8080
ENV MANAGEMENT_PORT 8084
ENV APP_ROOT /app
ENV WEB_CONCURRENCY 2
ENV MIN_THREADS 1
ENV MAX_THREADS 16

COPY Gemfile /app/
COPY Gemfile.lock /app/
RUN bundle install --without development test

COPY . /app
RUN mkdir -p /app/log /app/tmp && chown -R app:app /app
RUN RAILS_GROUPS=assets bundle exec rake assets:precompile

ENTRYPOINT ["/init"]
