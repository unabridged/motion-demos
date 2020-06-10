class CalculatorComponent < ViewComponent::Base
  include Motion::Component

  attr_reader :buffer, :buffering, :op, :total, :operand

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
    @total = total
    @buffering = true
    @buffer = ""
  end

  def one; @buffer << "1"; end
  def two; @buffer << "2"; end
  def three; @buffer << "3"; end
  def four; @buffer << "4"; end
  def five; @buffer << "5"; end
  def six; @buffer << "6"; end
  def seven; @buffer << "7"; end
  def eight; @buffer << "8"; end
  def nine; @buffer << "9"; end
  def zero; @buffer << "0"; end

  def add
    @operand = @buffer.to_f
    @op = :+
    @buffer = ""
  end

  def subtract
    @operand = @buffer.to_f
    @op = :-
    @buffer = ""
  end

  def multiply
    @operand = @buffer.to_f
    @op = :*
    @buffer = ""
  end

  def divide
    @operand = @buffer.to_f
    @op = :/
    @buffer = ""
  end

  def equals
    @total =
      case op
      when :+
        operand + @buffer.to_f
      when :-
        operand - @buffer.to_f
      when :*
        operand * @buffer.to_f
      when :/
        operand / @buffer.to_f
      end

    @buffering = false
  end

  def clear
    @total = 0
    @buffering = true
    @op = nil
    @operand = nil
    @buffer = ""
  end
end
