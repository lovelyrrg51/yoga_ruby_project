FactoryBot.define do
  factory(:aspect_feedback) do
    aspect_type "family_happiness"
    aspects_of_life { AspectsOfLife.first || association(:aspects_of_life)}
    deleted_at nil
    description_after nil
    descripton_before nil
    name nil
    rating_after 0
    rating_before 0
  end
end
