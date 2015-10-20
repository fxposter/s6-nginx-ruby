#!/usr/bin/with-contenv /bin/bash
cd /app
exec s6-setuidgid app bundle exec puma --config config/puma.rb
