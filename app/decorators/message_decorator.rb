class MessageDecorator < SimpleDelegator
  attr_accessor :checked, :starred


  def display_sent_at
    if created_at
  end


  def today?
    Time.now - 1.day < created_at
  end

  def this_month?
    Time.now - 1.month < created_at
  end

  def this_year?
    Time.now - 1.year < created_at
  end
end
