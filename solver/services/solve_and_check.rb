# frozen_string_literal: true

require_relative '_base'

module Solver
	module Services
		## Solve an equation, check via another service, save roots to database if everything is OK
		class SolveAndCheck < Base
			attr_reader :discriminant

			def initialize(equation)
				super()

				@equation = equation

				## Don't use mass assignment because getters can be redefined
				@a = @equation.a
				@b = @equation.b
				@c = @equation.c
			end

			def call
				## Return solved and checked result if exists
				return saved_roots if saved_roots

				return false unless calculate_discriminant

				calculate_roots

				DB.connection.transaction do
					@equation.update(@roots)

					## It should be before DB update, but this order is the given task
					raise Sequel::Rollback unless check_roots
				end

				@error ? false : @roots
			end

			private

			memoize def saved_roots
				x1 = @equation.x1
				x2 = @equation.x2

				return unless x1 && x2

				{ x1: x1, x2: x2 }
			end

			def calculate_discriminant
				@discriminant = @b**2 - 4 * @a * @c

				## `Math.sqrt` with negative value will raise exception
				if @discriminant.negative?
					@error = 'discriminant is negative'
					return
				end

				@discriminant_sqrt = Math.sqrt(@discriminant)
			end

			def calculate_roots
				@roots = {
					x1: (-1 * @b + @discriminant_sqrt) / (2 * @a),
					x2: (-1 * @b - @discriminant_sqrt) / (2 * @a)
				}.freeze
			end

			def check_roots
				check_result = Checker.connection.post 'check', @roots

				return true if check_result.success? && check_result.body['valid']

				## Probably there are should be different errors for non-success response and non-valid
				@error = 'check failed'
				false
			rescue Faraday::ConnectionFailed => e
				@error = "check service is not available: #{e.message}"
				false
			end
		end
	end
end
