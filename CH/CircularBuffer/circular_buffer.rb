# Challenge of the Week: Circular Buffer
# Pete Hanson
class CircularBuffer
  class BufferEmptyException < RuntimeError; end
  class BufferFullException < RuntimeError; end

  EMPTY = 0
  FULL = 1
  OTHER = 2

  def initialize(number_of_cells)
    @buffer = Array.new(number_of_cells)
    @read_index = @write_index = 0
  end

  def advance(pointer)
    pointer += 1
    (pointer == @buffer.size) ? 0 : pointer
  end

  def clear
    initialize(@buffer.size)
  end

  def empty_or_full_helper
    case
    when @read_index != @write_index then OTHER
    when @buffer[@read_index].nil?   then EMPTY # must check against nil
    else                                  FULL
    end
  end

  def empty?
    empty_or_full_helper == EMPTY
  end

  def full?
    empty_or_full_helper == FULL
  end

  def read
    fail(BufferEmptyException) if empty?
    result = @buffer[@read_index]
    @buffer[@read_index] = nil
    @read_index = advance(@read_index)
    result
  end

  def write(value)
    fail(BufferFullException) if full?
    write!(value)
  end

  def write!(value)
    return if value.nil?
    @read_index = advance(@read_index) if full?
    @buffer[@write_index] = value
    @write_index = advance(@write_index)
  end
end
