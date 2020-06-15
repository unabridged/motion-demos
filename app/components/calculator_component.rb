class CalculatorComponent < ViewComponent::Base
  include Motion::Component

  attr_reader :buffer, :buffering, :op, :operand_one, :next_number

  map_motion :clear
  map_motion :change_sign
  map_motion :percent
  map_motion :equals
  map_motion :add_char
  map_motion :operation

  def initialize(total: 0)
    @buffer = total.to_s
    @buffering = false
    @next_number = false
  end

  def add_char(event)
    str = event.target.data[:char]

    if !buffering
      @buffer = ""
      @buffering = true
    end

    if next_number
      @buffer = str
      @next_number = false
    else
      @buffer << str
    end
  end

  def operation(event)
    @operand_one = buffer.to_f
    @op = event.target.data[:op].to_sym
    @next_number = true
  end

  def change_sign
    amt = (buffer.to_f * -1)
    @buffer = drop_decimals(amt).to_s
  end

  def percent
    amt = (buffer.to_f / 100.0)
    @buffer = drop_decimals(amt).to_s
  end

  def equals
    total =
      case op
      when :+
        operand_one + buffer.to_f
      when :-
        operand_one - buffer.to_f
      when :*
        operand_one * buffer.to_f
      when :/
        operand_one / buffer.to_f
      end

    @buffer = drop_decimals(total)

    @buffering = false
  end

  def clear
    @buffering = false
    @op = nil
    @operand_one = nil
    @buffer = "0"
    @next_number = false
  end

  private

  def drop_decimals(num)
    if num == num.to_i
      num.to_i
    else
      num
    end
  end
end
