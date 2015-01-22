class Symbol

  def call(*argv, &block)
    case
    when block_given?
      -> argv, block, obj {
        self.to_proc[obj, *argv, &block]
      }.curry[argv, block]
    when argv.size > 0
      -> argv, obj {
        self.to_proc[obj, *argv]
      }.curry[argv]
    else
      self.to_proc
    end
  end
 
  def +@
    self.call
  end
 
  def +(argv)
    self.call(*argv)
  end

end
