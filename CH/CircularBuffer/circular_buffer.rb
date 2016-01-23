# Challenge of the Week: Circular Buffer
# Pete Hanson
class CircularBuffer
  class BufferEmptyException < RuntimeError; end
  class BufferFullException < RuntimeError; end

  def initialize(number_of_cells)
    @buffer = Array.new(number_of_cells)
    @read_index = @write_index = 0
  end

  def advance(pointer)
    pointer += 1
    (pointer == @buffer.size) ? 0 : pointer
  end

  def empty?
    @read_index == @write_index && @buffer[@read_index].nil?
  end

  def full?
    @read_index == @write_index && @buffer[@read_index]
  end

  def clear
    @buffer.fill(nil)
    @read_index = @write_index = 0
  end

  def read
    fail(BufferEmptyException) if empty?
    result = @buffer[@read_index]
    @buffer[@read_index] = nil
    @read_index = advance(@read_index)
    result
  end

  def write(value)
    return if value.nil?
    fail(BufferFullException) if full?
    @buffer[@write_index] = value
    @write_index = advance(@write_index)
  end

  def write!(value)
    return if value.nil?
    @read_index = advance(@read_index) if full?
    @buffer[@write_index] = value
    @write_index = advance(@write_index)
  end
end
