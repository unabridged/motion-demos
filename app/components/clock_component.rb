class ClockComponent < ViewComponent::Base
  include Motion::Component
  HOURS = 12
  MINUTES = 60
  SECONDS = 60
  DEGREES = 360

  stream_from "time:updated", :handle_time
  attr_reader :timezone

  map_motion :update_timezone


  def initialize(time: Time.now.utc)
    @time = time
    @theme = :light
    @timezone = "Etc/UTC"
    trigger_timer
  end

  def trigger_timer
    @to_time = @time + duration

    Thread.new do
      while Time.now < @to_time
        ActionCable.server.broadcast("time:updated", { time: Time.now.utc })
        sleep 1
      end
    end
  end


  def update_timezone(event)
    element = event.target
    @timezone = element.data[:value]
  end

  def time
    @time.in_time_zone(@timezone)
  end

  def time_display
    time.strftime("%I:%M:%S%p %Z")
  end

  def hour
    time.hour % HOURS
  end

  def hour_rotation
    hour * (DEGREES / HOURS)
  end

  def minute_rotation
    time.min * (DEGREES / MINUTES)
  end

  def second_rotation
    time.sec * (DEGREES / SECONDS)
  end

  def handle_time(msg)
    @time = Time.parse(msg["time"])
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
