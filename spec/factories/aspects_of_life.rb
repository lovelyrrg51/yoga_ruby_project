FactoryBot.define do
  factory(:aspects_of_life) do
    benefits_to_family nil
    deleted_at nil
    other_areas_of_improvement nil
    sadhak_profile { SadhakProfile.first || association(:sadhak_profile) }
  end
end
