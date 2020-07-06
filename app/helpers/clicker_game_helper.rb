module ClickerGameHelper
  CLASSES = %w[
    primary secondary success danger warning info light dark
  ].freeze
  BTN_CLASSES = CLASSES.flat_map do |k|
    ["btn-#{k}", "btn-outline-#{k}"]
  end - ["btn-outline-light"]

  def score_button(amt, text: nil)
    text ||= "#{amt < 0 ? "" : "+"}#{amt}"

    button_tag text, class: "btn #{random_btn_class}", data: { motion: "click", amt: amt }
  end

  def lucky_button(text)
    button_tag text, class: "btn #{random_btn_class}", data: { motion: "lucky_click" }
  end

  def random_btn_class
    BTN_CLASSES.sample
  end
end
