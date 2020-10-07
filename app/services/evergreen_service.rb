# frozen_string_literal: true

LBCC_LIBRARIES = [
  'LBCC Albany Campus Library',
  'LBCC Benton Center',
  'LBCC Healthcare Occupations Center'
].freeze

ITEM_TIERS = [
  # First tier: items that are available in the stack at an
  # LBCC library
  lambda { |item|
    item.status == 'Available' &&
      item.location != 'Reserves' &&
      LBCC_LIBRARIES.include?(item.owning_lib)
  },

  # Second tier: items that are available in the reserves
  # collection at an LBCC library
  lambda { |item|
    item.status == 'Available' &&
      item.location == 'Reserves' &&
      LBCC_LIBRARIES.include?(item.owning_lib)
  },

  # Third tier: items that are available at a non-LBCC library
  lambda { |item|
    item.status == 'Available' &&
      LBCC_LIBRARIES.exclude?(item.owning_lib)
  },

  # Final tier: items that are not available anywhere
  ->(item) { item.status != 'Available' }
].freeze

# Service that pulls only the most helpful holdings info from Evergreen
class EvergreenService
  # Return a single item from the highest possible tier
  def best_item(bib_id)
    ITEM_TIERS.each do |criteria|
      match = holdings_data(bib_id).copies.find(criteria)
      return match if match
    end
  end

  # Return an array of items, all from the same, highest possible tier
  def best_items(bib_id, limit = 5)
    ITEM_TIERS.each do |criteria|
      matches = holdings_data(bib_id).copies.select(&criteria)
      return matches.first(limit) if matches.any?
    end
  end

  # Return items, possibly from multiple different tiers
  def items(bib_id, limit = 10)
    all_matches = []
    ITEM_TIERS.each do |criteria|
      matches = holdings_data(bib_id).copies.select(&criteria)
      matches.each do |match|
        return all_matches if all_matches.length == limit

        all_matches << match
      end
    end
    all_matches
  end

  private

  def holdings_data(bib_id)
    Rails.cache.fetch("evergreen-#{bib_id}", expires_in: 1.day) do
      begin
        evergreen_connection = Rails.cache.fetch('evergreen_connection', expires_in: 1.day) do
          EvergreenHoldings::Connection.new 'https://libcat.linnbenton.edu'
        end
        evergreen_connection.get_holdings bib_id
      rescue StandardError
        nil
      end
    end
  end
end
