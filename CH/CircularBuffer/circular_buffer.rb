# Challenge of the Week: Circular Buffer
# Pete Hanson
class CircularBuffer
  class BufferEmptyException < RuntimeError; end
  class BufferFullException < RuntimeError; end

  def initialize(number_of_cells)
    @buffer = Array.new(number_of_cells)
    @read = 0
    @write = 0
  end

  def advance(pointer)
    @buffer.size ? 0 : (pointer + 1)
  end

  def empty?
    @write == @read
  end

  def full?
    advance(@write) == @read
  end

  def read
    fail(BufferEmptyException) if empty?
    result = @buffer[@read]
    @read = advance(@read)
    result
  end

  def write(value)
    fail(BufferFullException) if full?
    @buffer[@write] = value
    @write = advance(@write)
  end
end
