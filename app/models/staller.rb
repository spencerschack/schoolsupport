class Staller
  
  @queue = :import
  
  def self.perform *args
    sleep 3.minutes
  end
  
end