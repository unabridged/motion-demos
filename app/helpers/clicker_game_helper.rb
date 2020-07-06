module ClickerGameHelper
  def score_button(amt, btn:, text: nil)
    text ||= "#{amt < 0 ? "" : "+"}#{amt}"

    button_tag text, class: "btn #{btn}", data: { motion: "click", amt: amt }
  end
end
