class BufferEmptyException < Exception
end

class BufferFullException < Exception
end

class CircularBuffer

  def initialize(length)
    @buffer = Array.new(length)
    center = (@buffer.length/2).floor
    @reader = center
    @writer = center
  end

  def write!(value)
    if value == nil
      return
    end
    if @buffer[@writer] == nil
      self.write(value)
    else
      @reader += 1
      reader_wrap_check
      @buffer[@writer] = value
      @writer += 1
      writer_wrap_check
    end
  end

  def write(value)
    if value == nil
      return
    end
    if self.buffer_full?
      raise BufferFullException.new
    end
    @buffer[@writer] = value
    @writer += 1
    writer_wrap_check
  end

  def read
    if @buffer[@reader] == nil
      raise BufferEmptyException.new
    else
      value = @buffer[@reader].dup
      @buffer[@reader] = nil
      @reader += 1
      reader_wrap_check
      value
    end
  end

  def clear
    @buffer = Array.new(@buffer.length)
    center = (@buffer.length/2).floor
    @reader = center
    @writer = center
  end

  def writer_wrap_check
    if @writer > @buffer.length - 1
      @writer = 0
    elsif @writer < 0
      @writer = @buffer.length - 1
    end
  end

  def reader_wrap_check
    if @reader > @buffer.length - 1
      @reader = 0
    elsif @reader < 0
      @reader = @buffer.length - 1
    end
  end

  def buffer_full?
    if @buffer.include?(nil)
      return false
    else
      return true
    end
  end
end
