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

## Vision ##

Generally, the plan for this application is as follows:

* allow users to track their bets of how teams will perform against the line
* allow users to view results from past bets
* allow users to derive meaningful conclusions from past bets

This delivers value to customers, but creates value for a potential business:
* with legalized gambling, collecting data from casual users has value
* building user base which uses application for gambling training wheels has advertising value, potential sales/integration value with actual gambling platforms


### Models ###

* nba_lines
* nba_games
* users

nba_games have many nba_lines
nba_users have many nba_lines

### Applications ###

NbaLinesServer supervises db and api.

NbaLinesServer needs to be configured to run a cron job which:
* updates nba_games daily with the games for that day
* updates nba_lines daily with the nba_lines for the games for that day

User authentication needs to be configured:
* prevent users from interacting with the api without token
* add plug to handle authentication
* update tests to prove authentication is required