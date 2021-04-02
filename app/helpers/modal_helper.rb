module ModalHelper
  NUMBERS = {
    1 => "one",
    2 => "two",
    3 => "three",
    4 => "four",
    5 => "five"
  }

  def numbers_to_words(number)
    NUMBERS[number]
  end
end
