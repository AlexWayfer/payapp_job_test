# frozen_string_literal: true

describe Solver::Routes::API do
	include Rack::Test::Methods

	def app
		described_class
	end

	shared_context 'with requests by description' do |description|
		http_method, parsed_path = description.split
		http_method.downcase!

		subject do
			send http_method, path, payload, { 'CONTENT_TYPE' => 'application/json' }
			last_response
		end

		let(:parsed_path) { parsed_path }
		let(:path) { parsed_path }
	end

	shared_context 'with JSON body' do
		subject { JSON.parse(super().body) }
	end

	describe 'POST /api/equation' do
		include_context 'with requests by description', description

		context 'with params' do
			context 'when all params are correct' do
				let(:payload) { JSON.generate(a: 4, b: 8, c: 16) }

				describe 'status' do
					subject { super().status }

					it { is_expected.to eq 201 }
				end

				describe 'body' do
					include_context 'with JSON body'

					it { is_expected.to match 'id' => an_instance_of(Integer) }
				end
			end

			context 'with wrong types of params' do
				let(:payload) { JSON.generate(a: 'foo', b: true, c: [2]) }

				describe 'status' do
					subject { super().status }

					it { is_expected.to eq 400 }
				end

				describe 'body' do
					include_context 'with JSON body'

					it { is_expected.to match 'error' => 'a is invalid, b is invalid, c is invalid' }
				end
			end

			context 'when `a` equal to zero' do
				let(:payload) { JSON.generate(a: 0, b: 2, c: 4) }

				describe 'status' do
					subject { super().status }

					it { is_expected.to eq 400 }
				end

				describe 'body' do
					include_context 'with JSON body'

					it { is_expected.to match 'error' => 'a has a value not allowed' }
				end
			end
		end

		context 'without params' do
			let(:payload) { '' }

			describe 'status' do
				subject { super().status }

				it { is_expected.to eq 400 }
			end

			describe 'body' do
				include_context 'with JSON body'

				it { is_expected.to eq 'error' => 'a is missing, b is missing, c is missing' }
			end
		end
	end

	describe 'PATCH /api/equation/:id/solve' do
		include_context 'with requests by description', description do
			let(:path) { parsed_path.sub(':id', id.to_s) }
			let(:payload) { nil }
		end

		context 'with existing id' do
			let(:existing_equation) { Solver::Models::Equation.create(a_b_c) }
			let(:id) { existing_equation.id }

			context 'when discriminant is negative' do
				let(:a_b_c) { { a: 5, b: 3, c: 7 } }

				describe 'status' do
					subject { super().status }

					it { is_expected.to eq 400 }
				end

				describe 'body' do
					include_context 'with JSON body'

					it { is_expected.to match 'error' => 'discriminant is negative' }
				end
			end

			context 'when discriminant is not negative' do
				before do
					## I like VCR more
					Solver::Checker.connection.adapter :test, faraday_stubs
				end

				after do
					Solver::Checker.clear_memery_cache! :connection
				end

				let(:a_b_c) { { a: 1, b: -8, c: 12 } }

				context 'when check succeed' do
					let(:faraday_stubs) do
						Faraday::Adapter::Test::Stubs.new do |stub|
							stub.post('/api/check', JSON.generate(x1: 6.0, x2: 2.0)) do
								[200, { 'Content-Type': 'application/json' }, JSON.generate(valid: true)]
							end
						end
					end

					describe 'status' do
						subject { super().status }

						it { is_expected.to eq 200 }
					end

					describe 'body' do
						include_context 'with JSON body'

						it { is_expected.to match 'x1' => be_positive, 'x2' => be_positive }
					end
				end

				context 'when check failed' do
					let(:a_b_c) { { a: 1, b: -2, c: -3 } }

					let(:faraday_stubs) do
						Faraday::Adapter::Test::Stubs.new do |stub|
							stub.post('/api/check', JSON.generate(x1: 3.0, x2: -1.0)) do
								[200, { 'Content-Type': 'application/json' }, JSON.generate(valid: false)]
							end
						end
					end

					describe 'status' do
						subject { super().status }

						it { is_expected.to eq 400 }
					end

					describe 'body' do
						include_context 'with JSON body'

						it { is_expected.to match 'error' => 'check failed' }
					end
				end

				context 'when check service is not available' do
					let(:faraday_stubs) do
						Faraday::Adapter::Test::Stubs.new do |stub|
							stub.post('/api/check') do
								raise Faraday::ConnectionFailed, 'test fail'
							end
						end
					end

					describe 'status' do
						subject { super().status }

						it { is_expected.to eq 400 }
					end

					describe 'body' do
						include_context 'with JSON body'

						it { is_expected.to match 'error' => 'check service is not available: test fail' }
					end
				end
			end
		end

		context 'with nonexistent id' do
			let(:id) { 0 }

			describe 'status' do
				subject { super().status }

				it { is_expected.to eq 404 }
			end

			describe 'body' do
				include_context 'with JSON body'

				it { is_expected.to eq 'error' => "equation with `id = #{id}` not found" }
			end
		end
	end
end
