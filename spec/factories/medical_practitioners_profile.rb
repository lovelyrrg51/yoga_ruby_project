FactoryBot.define do
  factory(:medical_practitioners_profile) do
    current_professional_role "health_care_extender"
    deleted_at nil
    interested_in_panel_discussion false
    interested_in_volunteering false
    medical_degree "ToFactory: RubyParser exception parsing this attribute"
    medical_practitioner_speciality_area_id nil
    other_role ""
    other_speciality ""
    practiced_integrative_health_care false
    sadhak_profile_id 1
    work_enviroment "research"
  end
end
