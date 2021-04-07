# Simple calculator in Motion
class CalculatorComponent < ViewComponent::Base
  include Motion::Component
  # @!attribute [r] buffer
  #   @return [String] This attribute is a string of number chars representing
  #   the number the user is currently typing.  It is a string instead of a number
  #   because the user types it one character at a time.
  # @!attribute [r] op
  #   @return [Symbol or String] This attribute is the operation (+, -, *, /) that the
  #   user has chosen.
  # @!attribute [r] operand_one
  #   @return [Float] This attribute is the previously typed number or calculated
  #   value from all previous operations.
  attr_reader :buffer, :op, :operand_one

  OPERATIONS = %w[+ - * /].freeze

  map_motion :clear
  map_motion :change_sign
  map_motion :percent
  map_motion :equals
  map_motion :add_char
  map_motion :operation

  def initialize(total: 0)
    @buffer = total.to_s
  end

  def add_char(event)
    str = event.target.data[:char].dup
    if ["0", ""].include?(@buffer)
      str = "0." if str == "."
      @buffer = str
    else
      @buffer << str
    end
  end

  def operation(event)
    event_op = event_operation(event)
    return unless event_op

    @op = event_op if overwrite_operation?(event_op)
    return unless buffer.present?

    calculate
    next_ops(buffer, event_op)
  end

  def change_sign
    amt = (current_value.to_f * -1)
    change_current(amt)
  end

  def percent
    amt = (current_value.to_f / 100.0)
    change_current(amt)
  end

  def equals
    return if buffer.blank?

    calculate
    next_ops(current_value, nil)
  end

  def clear
    clear_ops
  end

  def current_value
    return operand_one if buffer.blank?

    buffer
  end

  private

  def calculate
    return unless op && operand_one && buffer.present?

    total = operand_one.send(op, buffer.to_f)
    change_current(total)
  end

  # Use this when you're not performing an operation but need to change current_value (%, +/-)
  def change_current(val)
    val = drop_decimals(val.to_f)
    ivar, ival = \
      if buffer.blank?
        ["@operand_one", val]
      else
        ["@buffer", val.to_s]
      end
    instance_variable_set(ivar, ival)
  end

  def drop_decimals(num)
    if num == num.to_i
      num.to_i
    else
      num
    end
  end

  def next_ops(current_buffer, operation)
    @operand_one = drop_decimals(current_buffer.to_f)
    @op = operation
    clear_buffer
  end

  def clear_ops
    next_ops(nil, nil)
  end

  def clear_buffer
    @buffer = ""
  end

  def event_operation(event)
    op = event.target.data[:op]
    op.to_sym if OPERATIONS.include?(op)
  end

  def overwrite_operation?(new_operation)
    # ie - if they clicked two operations in a row without adding numbers, use the last one
    op_changed = new_operation != op
    op_changed && buffer.blank?
  end
end
