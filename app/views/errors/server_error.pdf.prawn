pdf.text @exception.class.to_s.titleize
pdf.text @exception.message
@exception.backtrace.each do |line|
  pdf.text "- #{line}"
end