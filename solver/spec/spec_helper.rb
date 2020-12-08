# frozen_string_literal: true

ENV['RACK_ENV'] ||= 'test'

require 'rack/test'

require 'warning'

Warning.ignore(:missing_ivar, Gem.loaded_specs['sequel'].full_gem_path)

require_relative '../routes/api'

RSpec.configure do |config|
	config.around do |example|
		## https://sequel.jeremyevans.net/rdoc/files/doc/testing_rdoc.html#label-rspec+-3E-3D+2.8
		Solver::DB.connection.transaction(rollback: :always, auto_savepoint: true) { example.run }
	end
end
