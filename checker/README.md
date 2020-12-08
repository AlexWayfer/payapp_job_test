# Checker

## Setup

1.  Clone this repository and checkout to directory.
2.  Set the [`EDITOR` environment variable][1] (`nano`, `vim`, `mcedit`, etc.).
3.  Install Ruby >= 2.4.
4.  Run `bundle install` to install Ruby gems.

[1]: https://en.wikibooks.org/wiki/Guide_to_Unix/Environment_Variables#EDITOR

## Launch

```
bundle exec rackup -p 3001
```

## Testing

```
bundle exec rspec
```
