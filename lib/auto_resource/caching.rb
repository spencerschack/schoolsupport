module Caching
  
  # Cache path is generated from the name of the model, the timestamp of the
  # most recently updated row, and a hash of the ids of the collection.
  #
  # The cache path is calculated in this way to prevent the following:
  # - incorrect presentation when records have been deleted
  # - incorrect presentation when records have been updated
  # - incorrect presentation when records are not present in the set
  def self.included base
    base.caches_action :index,
      layout: false,
      cache_path: proc { |controller|
        sql = collection.reorder('').select("string_agg(id::text, ',')").to_sql
        digest = Digest::SHA1.hexdigest ActiveRecord::Base.connection.execute(sql).to_a.to_s
        "#{collection.cache_key}-#{digest}"
      }
  end
  
end