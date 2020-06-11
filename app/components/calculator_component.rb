class CalculatorComponent < ViewComponent::Base
  include Motion::Component

  attr_reader :buffer, :buffering, :op, :operand_one, :next_number

  map_action :clear

  map_action :change_sign
  map_action :percent

  map_action :zero
  map_action :one
  map_action :two
  map_action :three
  map_action :four
  map_action :five
  map_action :six
  map_action :seven
  map_action :eight
  map_action :nine

  map_action :add
  map_action :subtract
  map_action :multiply
  map_action :divide
  map_action :equals

  map_action :decimal

  def initialize(total: 0)
    @buffer = total.to_s
    @buffering = false
    @next_number = false
  end

  def one; add_to_buffer("1"); end
  def two; add_to_buffer("2"); end
  def three; add_to_buffer("3"); end
  def four; add_to_buffer("4"); end
  def five; add_to_buffer("5"); end
  def six; add_to_buffer("6"); end
  def seven; add_to_buffer("7"); end
  def eight; add_to_buffer("8"); end
  def nine; add_to_buffer("9"); end
  def zero; add_to_buffer("0"); end
  def decimal; add_to_buffer("."); end

  def add; set_op(:+); end
  def subtract; set_op(:-); end
  def multiply; set_op(:*); end
  def divide; set_op(:/); end

  def change_sign
    amt = (@buffer.to_f * -1)
    @buffer = drop_decimals(amt).to_s
  end

  def percent
    amt = (@buffer.to_f / 100.0)
    if amt == amt.to_i
      @buffer = amt.to_i.to_s
    else
      @buffer = amt.to_s
    end
  end

  def equals
    total =
      case op
      when :+
        operand_one + @buffer.to_f
      when :-
        operand_one - @buffer.to_f
      when :*
        operand_one * @buffer.to_f
      when :/
        operand_one / @buffer.to_f
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

  def add_to_buffer(str)
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

  def set_op(operation)
    @operand_one = @buffer.to_f
    @op = operation
    @next_number = true
  end

  def drop_decimals(num)
    if num == num.to_i
      num.to_i
    else
      num
    end
  end

end
