module Paperclip
  
  class Ttf < Processor
    
    attr_accessor :file
    
    def initialize file, options = {}, attachment = nil
      @file = file
    end
    
    def make
      arguments = '-script '
      arguments << "'#{Rails.root}/lib/paperclip_processors/convert.pe' "
      arguments << "'#{@file.path}'"
      Paperclip.run('fontforge', arguments)
      File.open(@file.path.sub(File.extname(@file.path), '.ttf'))
    end
    
  end
  
end