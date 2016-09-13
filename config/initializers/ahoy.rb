if Rails.env.production?
  class Ahoy::Store < Ahoy::Stores::ActiveRecordStore
    # customize here
  end
end
