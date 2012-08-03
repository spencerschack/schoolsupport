module Paperclip
  class Attachment
    
    def url style_name = default_style, options = {}
      expiring_url(60, style_name)
    end
    
  end
end

Paperclip.interpolates :style_unless_original do |attachment, style|
  "-#{style}" unless style == :original
end