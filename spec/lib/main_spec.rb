# frozen_string_literal: true

require_relative '../../lib/main'

describe Main do
  context 'for input sanitation' do
    it 'drops commas'
    it 'trims whitespaces'
    it 'removes duplicates'
    it 'removes URL hostile characters'
  end

  it 'works' do
    # TODO: use HTTP mock adapter to stub out actual calls to the API
    # Main.run(%w[bulldog-boston  ,  bulldog, xxx  hound bulldog <>#%{}|\^~[]`])
  end

  context 'returns non-zero return code' do
    it 'for non-existent breeds'
    it 'for API failures'
  end
end
