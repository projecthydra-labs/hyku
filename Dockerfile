FROM upress/hyku-base:latest

ADD . /data

RUN bundle exec rake assets:precompile

COPY ./docker/supervisord-rails.conf /etc/supervisor/supervisord-rails.conf
COPY ./docker/supervisord-worker.conf /etc/supervisor/supervisord-worker.conf
COPY ./docker/supervisord-worker-sidekiq.conf /etc/supervisor/supervisord-worker-sidekiq.conf

EXPOSE 3000

ENTRYPOINT  ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord-rails.conf"]
