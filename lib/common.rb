class String
  def bold
    "\e[1m#{self}\e[22m"
  end
end
