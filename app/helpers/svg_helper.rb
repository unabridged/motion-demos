module SvgHelper
  def svg(name, options = {})
    default_options = {width: "1em", height: "1em", viewBox: "0 0 16 16", xmlns: "http://www.w3.org/2000/svg"}
    content_tag(:svg, default_options.merge(options)) do
      content_tag(:use, nil, {"xlink:href" => "#bootstrap-icons.svg##{name}"})
    end
  end
end
