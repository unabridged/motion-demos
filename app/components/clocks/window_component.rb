class Clocks::WindowComponent < ViewComponent::Base
  MORNING_HOUR = 7
  EVENING_HOUR = 21
  MIDDAY = 14

  def initialize(time:, timezone:)
    @time = time
    @timezone = timezone
  end

  def time
    @time.in_time_zone(@timezone)
  end

  def hour
    time.hour
  end

  def last_hour
    (hour - 1) % 24
  end

  def dawn_or_dusk?
    hour == MORNING_HOUR || hour == EVENING_HOUR
  end

  def night?
    hour < MORNING_HOUR || hour > EVENING_HOUR
  end

  def sky_style
    color1, color2 = hour_colors

    "background: linear-gradient(0, #{color1} 0%, #{color2} 100%);"
  end

  def dawn_color
    "#ff9eda"
  end

  def sun_color
    SUN_COLORS[hour]
  end

  def hour_colors
    return [dawn_color, sky_color(hour)] if dawn_or_dusk?

    [sky_color(hour), sky_color(last_hour)]
  end

  def sky_color(hour)
    SKY_COLORS[hour]
  end

  def half_day_length
    (EVENING_HOUR - MORNING_HOUR).to_f / 2.0
  end

  def sun_position
    return "-100" if night?

    (half_day_length - (MIDDAY - hour).abs) / half_day_length * 100
  end

  SUN_COLORS = {
    7 => "#e36700",
    8 => "#f2740b",
    9 => "#e59a27",
    10 => "#e59a27",
    11 => "#e59a27",
    12 => "#d69415",
    13 => "#f2c559",
    14 => "#f2c559",
    15 => "#f2c559",
    16 => "#d69415",
    17 => "#e59a27",
    18 => "#e59a27",
    19 => "#e59a27",
    20 => "#f2740b",
    21 => "#e36700"
  }

  SKY_COLORS = {
    1 => "#2e4482",
    2 => "#2e4482",
    3 => "#131862",
    4 => "#2e4482",
    5 => "#546bab",
    6 => "#87889c",
    7 => "#bea9de",
    8 => "#0484fc",
    9 => "#0494fc",
    10 => "#099ffc",
    11 => "#44b7fc",
    12 => "#6cc4fc",
    13 => "#76d5fc",
    14 => "#90e3fc",
    15 => "#9fe9fc",
    16 => "#90e3fc",
    17 => "#76d5fc",
    18 => "#6cc4fc",
    19 => "#44b7fc",
    20 => "#099ffc",
    21 => "#0494fc",
    22 => "#87889c",
    23 => "#546bab",
    0 => "#546bab"
  }
end
