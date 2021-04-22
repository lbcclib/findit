# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../../../lib/tasks/data/config/personal_names.macro'

describe 'personal name indexing' do
  it 'puts lastname first names into direct order' do
    original_names = [
      'Fadali, M. Sami',
      'Evrendilek, Fatih',
      'York, Stacey'
    ]
    reordered_names = FindIt::Macros::PersonalNames.to_direct_order.call(nil, original_names)

    expected_names = [
      'M. Sami Fadali',
      'Fatih Evrendilek',
      'Stacey York'
    ]

    expect(reordered_names).to eq(expected_names)
  end

end
