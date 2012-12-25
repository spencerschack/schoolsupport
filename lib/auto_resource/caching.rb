module Caching
  
  # Cache path is generated from the name of the model, the timestamp of the
  # most recently updated row, and a hash of the ids of the collection.
  #
  # The cache path is calculated in this way to prevent the following:
  # - incorrect presentation when records have been deleted
  # - incorrect presentation when records have been updated
  # - incorrect presentation when records are not present in the set
  # create - check
  # updated - check
  # 

  def self.included base

    base.caches_action :index,
      layout: false,
      cache_path: proc { |controller|
        "#{collection.cache_key}-#{Digest::SHA1.hexdigest(collection.pluck(:id).to_s)}"
      }

    base.helper_method :offset_amount
  end
  
  def offset_amount
    @offset_amount ||= ENV['PAGE_OFFSET_AMOUNT'].to_i
  end

end