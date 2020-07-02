module CountriesHelper
  def country_options
    ISO3166::Country.all.map do |c|
      [c.name, c.alpha2]
    end.sort_by(&:first)
  end

  def state_options(country=nil)
    return [] unless country

    ISO3166::Country[country].subdivisions.map do |key, sub|
      [sub.translations["en"], key]
    end.sort_by(&:first)
  end
end
