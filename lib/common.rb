class String
  def bold
    "\e[1m#{self}\e[22m"
  end

  def naturalized
    scan(/\d+|\D+/).map { |part| part.match(/\d+/) ? part.to_i : part }
  end
end
