class String
  def bold
    "\e[1m#{self}\e[22m"
  end

  def naturalized
    scan(/[^\d\.]+|[\d\.]+/).collect { |f| f.match(/\d+(\.\d+)?/) ? f.to_f : f }
  end
end
