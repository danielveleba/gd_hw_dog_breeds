# frozen_string_literal: true

require 'webmock/rspec'

require_relative '../../lib/main'

# rubocop:disable Metrics/BlockLength
describe Main do
  context 'for input sanitation' do
    it 'drops commas'
    it 'trims whitespaces'
    it 'removes duplicates'
    it 'removes URL hostile characters'
  end

  # I don't mind creating the files on FS as tests are usually run
  # in a single-purpose container
  it 'works for valid args' do
    stub_request(:get, 'https://dog.ceo/api/breed/bulldog/boston/images')
      .to_return(body: { message: %w[bb1 bb2], status: 'success' }.to_json,
                 headers: { 'Content-Type' => 'application/json' })
    stub_request(:get, 'https://dog.ceo/api/breed/bulldog/images')
      .to_return(body: { message: %w[b1 b2], status: 'success' }.to_json,
                 headers: { 'Content-Type' => 'application/json' })
    stub_request(:get, 'https://dog.ceo/api/breed/hound/images')
      .to_return(body: { message: %w[h1 h2], status: 'success' }.to_json,
                 headers: { 'Content-Type' => 'application/json' })

    out_dirs_pre = Dir.glob('out*')

    # rubocop:disable Layout/SpaceInsideArrayPercentLiteral
    Main.run(%w[bulldog-boston  , bulldog hound bulldog])
    # rubocop:enable Layout/SpaceInsideArrayPercentLiteral

    out_dirs_post = Dir.glob('out*')
    dir = (out_dirs_post - out_dirs_pre)[0]
    expect(Dir.children(dir)).to include('bulldog.csv', 'bulldog-boston.csv',
                                         'hound.csv', 'updated_at.json')

    # TODO: check file contents

    assert_requested :get, 'https://dog.ceo/api/breed/bulldog/boston/images',
                     times: 1
    assert_requested :get, 'https://dog.ceo/api/breed/bulldog/images',
                     times: 1
    assert_requested :get, 'https://dog.ceo/api/breed/hound/images',
                     times: 1

    expect(Main.ret).to eql(0)
  end

  context 'returns non-zero return code' do
    it 'for non-existent breeds'
    it 'for API failures'
    it 'for invalid input' # /<>#%{}|\^~[]`
  end
end
# rubocop:enable Metrics/BlockLength
