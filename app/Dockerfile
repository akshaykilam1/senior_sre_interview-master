FROM ruby:2.6.3-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
  build-essential \
  libssl-dev \
  libreadline-dev \
  zlib1g-dev \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . /app/

RUN gem install bundler -v 2.4.22 && bundle install

EXPOSE 4567

CMD ["bundle", "exec", "ruby", "simpsons_simulator.rb", "-o", "0.0.0.0"]
