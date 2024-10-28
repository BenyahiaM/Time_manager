# Use the latest Elixir version
FROM elixir:1.14-alpine

# Install dependencies for Elixir and Phoenix
RUN apk add --no-cache build-base git inotify-tools postgresql-client

# Set up Hex and Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Set environment variable
ENV ADMIN_KEY=I/fqYUYqWzWDweQNe7Fdhid6gkSJ7S1HekNzWpkr6hJJ3pj3qsXu/dDqwtMXLQkn

# Set the working directory
WORKDIR /app

# Copy only the mix files to install dependencies in a separate layer
COPY mix.exs mix.lock ./

# Install Elixir dependencies
RUN mix deps.get

# Copy the remaining application files
COPY . .

# Generate Swagger docs and compile
RUN mix phx.swagger.generate
RUN mix compile

# Expose Phoenix server port
EXPOSE 4000

# Default command to start the server
CMD ["mix", "phx.server"]
