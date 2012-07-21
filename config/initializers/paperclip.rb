module Paperclip
  class Attachment
    
    def url style_name = default_style, options = {}
      expiring_url(60, style_name)
    end
    
  end
end