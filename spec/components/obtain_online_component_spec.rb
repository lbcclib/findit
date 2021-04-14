require 'rails_helper'

RSpec.describe ObtainOnlineComponent, type: :component do
  it 'delivers a reasonable string when format is not known' do
    component = described_class.new(document: SolrDocument.new('id' => '12345', 'title' => 'Hello World'))
    expect(component.string).to eq(I18n.t('obtain.resource'))
  end

  it 'delivers a reasonable string when format is an empty string' do
    component = described_class.new(document: SolrDocument.new('id' => '12345', 'format' => '', 'title' => 'Hello World'))
    expect(component.string).to eq(I18n.t('obtain.resource'))
  end

  it 'delivers a customized string when format is Ebook' do
    component = described_class.new(document: SolrDocument.new('id' => '12345', 'title' => 'Hello World',
                                                               'format' => 'Ebook'))
    expect(component.string).to eq(I18n.t('obtain.ebook'))
  end

  it 'delivers a customized string when format does not have its own predefined format' do
    component = described_class.new(document: SolrDocument.new('id' => '12345', 'title' => 'Hello World',
                                                               'format' => 'Espresso machine'))
    expect(component.string).to eq(I18n.t('obtain.general_online', type: 'Espresso machine'))
  end
end
