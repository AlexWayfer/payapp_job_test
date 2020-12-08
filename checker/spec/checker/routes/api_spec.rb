# frozen_string_literal: true

describe Checker::Routes::API do
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

	describe 'POST /api/check' do
		include_context 'with requests by description', description

		context 'with params' do
			context 'when all params are correct' do
				context 'when all roots are positive' do
					let(:payload) { JSON.generate(x1: 4, x2: 8) }

					describe 'status' do
						subject { super().status }

						it { is_expected.to eq 200 }
					end

					describe 'body' do
						include_context 'with JSON body'

						it { is_expected.to match 'valid' => true }
					end
				end

				context 'when not all roots are positive' do
					let(:payload) { JSON.generate(x1: 4, x2: -8) }

					describe 'status' do
						subject { super().status }

						it { is_expected.to eq 200 }
					end

					describe 'body' do
						include_context 'with JSON body'

						it { is_expected.to match 'valid' => false }
					end
				end
			end

			context 'with wrong types of params' do
				let(:payload) { JSON.generate(x1: 'foo', x2: [2]) }

				describe 'status' do
					subject { super().status }

					it { is_expected.to eq 400 }
				end

				describe 'body' do
					include_context 'with JSON body'

					it { is_expected.to match 'error' => 'x1 is invalid, x2 is invalid' }
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

				it { is_expected.to eq 'error' => 'x1 is missing, x2 is missing' }
			end
		end
	end
end
