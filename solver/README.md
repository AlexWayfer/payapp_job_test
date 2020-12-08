# Solver

## Setup

1.  Clone this repository and checkout to directory.
2.  Set the [`EDITOR` environment variable][1] (`nano`, `vim`, `mcedit`, etc.).
3.  Install Ruby >= 2.4.
4.  Run `bundle install` to install Ruby gems.
5.  Run `toys config check` to fill configs.
6.  Setup database
    1.  Install PostgreSQL.
    2.  Create a project user:
        `createuser -U postgres solver`
        (with `-P` for network-open databases)
    3.  Run `toys db create` to create database.
    4.  Run `toys db migrate` to run database migrations.

[1]: https://en.wikibooks.org/wiki/Guide_to_Unix/Environment_Variables#EDITOR

## Launch

```
bundle exec rackup -p 3000
```

## Testing

Don't forget about `toys db create` and `toys db migrate` with `RACK_ENV=test`.

```
bundle exec rspec
```
