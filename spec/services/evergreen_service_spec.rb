# frozen_string_literal: true

require 'spec_helper'

describe 'evergreen service' do
  it 'chooses the correct items amongst LBCC materials' do
    lbcc_available = EvergreenHoldings::Item.new({
                                                   status: 'Available',
                                                   location: 'Stacks',
                                                   owning_lib: 'LBCC Albany Campus Library'
                                                 })

    lbcc_childrens = EvergreenHoldings::Item.new({
                                                   status: 'Available',
                                                   location: 'Children\'s Chapter Books',
                                                   owning_lib: 'LBCC Albany Campus Library'
                                                 })

    lbcc_reserves = EvergreenHoldings::Item.new({
                                                  status: 'Available',
                                                  location: 'Reserves',
                                                  owning_lib: 'LBCC Benton Center'
                                                })

    status = double
    connection = double
    status.stub(:copies) { [lbcc_reserves, lbcc_childrens, lbcc_available] }

    record_id = 1

    Rails.cache.stub(:fetch).and_return(status)

    service = EvergreenService.new connection
    expect(service.best_item(record_id)).to eq(lbcc_childrens)
    expect(service.best_items(record_id)).to eq([lbcc_available, lbcc_childrens])
  end

  it 'chooses LBCC reserves before a partner library holdings' do
    scio_available = EvergreenHoldings::Item.new({
                                                   status: 'Available',
                                                   location: 'Stacks',
                                                   owning_lib: 'Scio Public Library'
                                                 })

    lbcc_reserves = EvergreenHoldings::Item.new({
                                                  status: 'Available',
                                                  location: 'Reserves',
                                                  owning_lib: 'LBCC Benton Center'
                                                })

    status = double
    connection = double
    status.stub(:copies) { [lbcc_reserves, scio_available] }

    record_id = 1

    Rails.cache.stub(:fetch).and_return(status)

    service = EvergreenService.new connection
    expect(service.best_item(record_id)).to eq(lbcc_reserves)
  end

  it 'chooses partner libraries before unavailable LBCC' do
    scio_available = EvergreenHoldings::Item.new({
                                                   status: 'Available',
                                                   location: 'Stacks',
                                                   owning_lib: 'Scio Public Library'
                                                 })

    lbcc_unavailable = EvergreenHoldings::Item.new({
                                                     status: 'Checked out',
                                                     location: 'Reserves',
                                                     owning_lib: 'LBCC Benton Center'
                                                   })

    status = double
    connection = double
    status.stub(:copies) { [lbcc_unavailable, scio_available] }

    record_id = 1

    Rails.cache.stub(:fetch).and_return(status)

    service = EvergreenService.new connection
    expect(service.best_item(record_id)).to eq(scio_available)
  end

  it 'chooses unavailable if nothing else exists' do
    scio_unavailable = EvergreenHoldings::Item.new({
                                                     status: 'Lost',
                                                     location: 'Stacks',
                                                     owning_lib: 'Scio Public Library'
                                                   })

    lbcc_unavailable = EvergreenHoldings::Item.new({
                                                     status: 'Checked out',
                                                     location: 'Reserves',
                                                     owning_lib: 'LBCC Benton Center'
                                                   })

    status = double
    connection = double
    status.stub(:copies) { [lbcc_unavailable, scio_unavailable] }

    record_id = 1

    Rails.cache.stub(:fetch).and_return(status)

    service = EvergreenService.new connection
    expect(service.best_item(record_id)).to eq(lbcc_unavailable)
  end
end
