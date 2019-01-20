# NbaLinesServer

**Backend Service allowing users to performance against NBA lines**

## Requirements

* Elixir 1.8.0
* Erlang 21.0
* Postgresql 10.6

## Setup

```
# install dependencies
mix deps.get

# create development db
mix ecto.create
mix ecto.migrate

# create test db
MIX_ENV=test mix ecto.create
MIX_ENV=test mix ecto.migrate

# run tests
mix test

# run server dev
mix s
```