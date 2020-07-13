class MessageDecorator < SimpleDelegator
  include ActionView::Helpers::DateHelper

  attr_accessor :checked, :starred
  THIS_MONTH_FORMAT = "%m/%d"
  DATE_FORMAT = "%m/%d/%y"

  def display_sent_at
    return sent_at_duration if today?
    return "#{sent_at_day_and_time} (#{sent_at_duration})" if this_month?
    return sent_at_day_and_time if this_month?

    sent_at_date
  end

  def sent_at_duration
    "#{distance_of_time_in_words(Time.now, created_at)} ago"
  end

  def sent_at_day_and_time
    created_at.strftime(THIS_MONTH_FORMAT)
  end

  def sent_at_date
    created_at.strftime(DATE_FORMAT)
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
