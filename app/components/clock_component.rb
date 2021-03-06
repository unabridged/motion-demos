class ClockComponent < ViewComponent::Base
  include Motion::Component
  HOURS = 12
  MINUTES = 60
  SECONDS = 60
  DEGREES = 360
  DATE_FORMAT = "%I:%M:%S%p %Z"

  attr_reader :timezone

  map_motion :update_timezone

  every 1.second, :tick

  def initialize(time: Time.now.utc)
    @time = time
    @timezone = "Etc/UTC"
    @timestart = @time
    @to_time = @time + duration
  end

  def tick
    @time = Time.now.utc

    stop_periodic_timer :tick if @time >= @to_time
  end

  def update_timezone(event)
    element = event.target
    @timezone = element.data[:value]
  end

  def time
    @time.in_time_zone(@timezone)
  end

  def timestart_display
    @timestart.strftime(DATE_FORMAT)
  end

  def time_display
    time.strftime(DATE_FORMAT)
  end

  def duration_display
    distance_of_time_in_words(duration)
  end

  def hour
    time.hour % HOURS
  end

  def hour_rotation
    (hour + minute_percent) * (DEGREES / HOURS).to_f
  end

  def minute_percent
    time.min / MINUTES.to_f
  end

  def minute_rotation
    time.min * (DEGREES / MINUTES)
  end

  def second_rotation
    time.sec * (DEGREES / SECONDS)
  end

  def completed?
    @time > @to_time
  end

  def percent_completed
    (@to_time - @time) / duration.to_i * 100
  end

  def time_remaining
    distance_of_time_in_words(@to_time - @time)
  end

  def duration
    5.minutes
  end
end
