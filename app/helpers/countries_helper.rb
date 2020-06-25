module CountriesHelper
  def country_options
    ISO3166::Country.all.map do |c|
      [c.name, c.alpha2]
    end.sort_by(&:first)
  end

  def state_options(country=nil)
    return [] unless country

    ISO3166::Country[country].subdivisions.map do |s|
      [s[1].name, s[0]]
    end.sort_by(&:first)
  end
end
