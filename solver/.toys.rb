# frozen_string_literal: true

include :bundler, static: true

require 'config_toys'
expand ConfigToys::Template, config_dir: "#{__dir__}/config"

require_relative 'config/main'

db_connection_proc = proc { Solver::DB.connection }

require 'psql_toys'
expand PSQLToys::Template,
	db_config_proc: proc { Solver::DB.configuration },
	db_connection_proc: db_connection_proc,
	db_extensions: %w[].freeze

alias_tool :db, :database

require 'sequel_migrations_toys'
expand SequelMigrationsToys::Template, db_connection_proc: db_connection_proc
