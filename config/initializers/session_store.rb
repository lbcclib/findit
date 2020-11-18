# frozen_string_literal: true

# Be sure to restart your server when you modify this file.
unless Rails.env.indexer?
  Rails.application.config.session_store :active_record_store,
                                         key: '_findit_session',
                                         expire_after: 2.weeks
end
