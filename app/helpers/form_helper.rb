module FormHelper
  def validation_messages(obj, field)
    return unless obj.errors[field].any?

    content_tag(:div, class: "invalid-feedback") do
      obj.errors.full_messages_for(field).to_sentence
    end
  end

  def valid_class(changed_set, obj, field)
    return "" unless changed_set.include? field

    obj.errors[field].any? ? "is-invalid" : "is-valid"
  end
end
