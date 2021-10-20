# frozen_string_literal: true

require 'spec_helper'

describe BentoController do
  it '#search_action_url returns a url within the bento controller' do
    options = { q: 'research topic',
                search_field: 'all_fields' }
    expect(controller.search_action_url(options)).to include('/search?')
  end

end
