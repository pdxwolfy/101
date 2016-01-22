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

  def read
    fail(BufferEmptyException) if @read == @write
    result = @buffer[@read]
    @read = advance(@read)
    result
  end

  def write(value)
    next_write = advance(@write)
    fail(BufferFullException) if next_write == @read
    @buffer[@write] = value
    @write = next_write
  end
end
