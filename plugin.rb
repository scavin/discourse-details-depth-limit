# frozen_string_literal: true

# name: discourse-details-depth-limit
# about: Limit nested details to 2 levels
# version: 0.3.0
# authors: Appinn

after_initialize do
  validate(:post, :validate_details_depth_limit) do
    if new_record? || raw_changed?
      source = raw.to_s

      if source.match?(/\[details(?==|\]|\s)|<details\b/i)
        html = PrettyText.cook(source)
        fragment = Nokogiri::HTML5.fragment(html)

        too_deep = fragment.css("details").any? do |node|
          node.ancestors.count { |a| a.name == "details" } >= 2
        end

        if too_deep
          messages = {
            "zh_CN" => "折叠内容最多允许嵌套 2 层，请减少嵌套层数后重新提交。",
            "en" => "Collapsible sections can only be nested up to 2 levels. Please reduce the nesting depth and try again.",
            "de" => "Aufklappbare Abschnitte dürfen maximal 2 Ebenen tief verschachtelt sein. Bitte reduzieren Sie die Verschachtelungstiefe und versuchen Sie es erneut.",
            "fr" => "Les sections repliables ne peuvent pas être imbriquées sur plus de 2 niveaux. Veuillez réduire la profondeur d'imbrication et réessayer."
          }

          locale = I18n.locale.to_s
          message = messages.fetch(locale, messages["en"])

          errors.add(:base, message)
        end
      end
    end
  end
end
