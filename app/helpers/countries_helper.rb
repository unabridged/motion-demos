module CountriesHelper
  def country_options
    ISO3166::Country.all.map { |c|
      [c.name, c.alpha2]
    }.sort_by(&:first)
  end

  def state_options(country = nil)
    return [] unless country

    ISO3166::Country[country].subdivisions.map { |key, sub|
      [sub.translations["en"], key]
    }.sort_by(&:first)
  end
end
