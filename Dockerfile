FROM ruby:3.1-alpine as build

# Add Gem build requirements
RUN apk add --no-cache g++ make

# Create app directory
WORKDIR /app

# Add Gemfile and Gemfile.lock
ADD Gemfile* /app/

# Install Gems
RUN gem install bundler -v 2.4.5 \
    && bundle config build.nokogiri --use-system-libraries \
    && bundle config --global jobs $(nproc) \
    && bundle install

# Copy Site Files
COPY . .

# Run jekyll serve
CMD ["bundle","exec","jekyll","serve","--host=0.0.0.0","-wl"]
