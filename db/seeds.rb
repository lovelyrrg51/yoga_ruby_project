# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#Hai this is test
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# Environment variables (ENV['...']) can be set in the file .env file.
# puts 'DEFAULT USERS'
# user = User.find_or_create_by(:email => ENV['ADMIN_EMAIL']) do |u|
#   u.name = ENV['ADMIN_NAME']
#   u.password = ENV['ADMIN_PASSWORD']
#   u.password_confirmation = ENV['ADMIN_PASSWORD']
#   u.skip_confirmation!
# end
#puts 'user: ' << user.name
#user.save

# user = User.find_or_create_by(:email => "jayyagnik@gmail.com") do |u|
#   puts "creating account"
#   u.username = 'adminuser'
#   u.name = "Jay"
#   u.last_name = "Yagnik"
#   u.password = "testtest"
#   u.password_confirmation = "testtest"
#   u.super_admin = true;
#   u.country_id = 113
#   # u.skip_confirmation!
# end
# user.save!
#puts 'user: ' << user.name
#user.save

# user = User.find_or_create_by(:email => "test2@test.com") do |u|
#   u.name = "Test"
#   u.username = 'testuser'
#   u.last_name = "Account"
#   u.password = "testtest"
#   u.password_confirmation = "testtest"
#   u.country_id = 113
#   # u.skip_confirmation!
# end
# user.save!
#puts 'user: ' << user.name

# User.find_or_initialize_by(:email => "test2@test.com").update_attributes(super_admin: true, digital_store_admin: true)

# user = User.find_or_create_by(:email => "user@test.com") do |u|
#   u.name = "Test"
#   u.last_name = "User"
#   u.password = "testtest"
#   u.password_confirmation = "testtest"
#   u.super_admin = true
#   u.digital_store_admin = true
#   u.country_id = 113
#   # u.skip_confirmation!

# end
# user.save!
#puts 'user: ' << user.name

# user = User.find_or_create_by(:email => "lokesh@mds.asia") do |u|
#   u.name = "Lokesh"
#   u.last_name = "Arora"
#   u.password = "metadesi"
#   u.password_confirmation = "metadesi"
#   u.super_admin = true
#   u.digital_store_admin = true
#   u.skip_confirmation!

# end
# user.save!
#puts 'user: ' << user.name


## DEFAULT ROLES ##

# Store Admin
# Role.find_or_create_by(name: "store_admin"){|role| role.description = "Admin for Spree Storefront"}

# puts "Adding Tag collections"
# t = TagCollection.find_or_create_by(name: "ShivYog Specials")
# t.menu_id = 2
# t.save

# puts "Adding Ticket Admin User Group"
# t = TicketGroup.find_or_create_by(name: "Ticket Admins")
# t.save

# puts "Starting to build digital assets"
# # .tap is so that the block runs even if the record is found and not created. comes in handy when adding new fields to the table
# asset = DigitalAsset.find_or_create_by(:asset_name => "Chants of Krishna part 1").tap do |a|
#    a.asset_description = "Sacred chants of Krishna Part 1"
#    a.asset_type = "vimeo_video"
#    a.video_id = "100967796"
#    a.price = 1
#    a.allowable_promo_code = "[\"om namo bhagavate vasudevaya\"]"
#    a.asset_vimeo_embed_link = "<iframe src=\"//player.vimeo.com/video/100967796?title=0&amp;byline=0&amp;portrait=0&amp;color=ff9933\" width=\"500\" height=\"281\" frameborder=\"0\" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>"
#    a.asset_list_thumbnail_url = "http:\/\/i.vimeocdn.com\/video\/482622384_200x150.jpg"
#    a.asset_large_thumbnail_url = "http:\/\/i.vimeocdn.com\/video\/482622384_640.jpg"
# end
# puts "digital asset: " << asset.asset_name
# puts "id is " << asset.video_id
# puts "large thumbnail url is " << asset.asset_large_thumbnail_url
# asset.save

# asset = DigitalAsset.find_or_create_by(:asset_name => "Chants of Krishna part 2").tap do |a|
#   a.asset_description = "Sacred chants of Krishna Part 2"
#   a.asset_type = "vimeo_video"
#   a.video_id = "100968606"
#   a.price = 1
#   a.allowable_promo_code = "[\"om namo bhagavate vasudevaya\"]"
#   a.asset_vimeo_embed_link = "<iframe src=\"//player.vimeo.com/video/100968606\" width=\"500\" height=\"400\" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>"
#   a.asset_list_thumbnail_url = "http:\/\/i.vimeocdn.com\/video\/482623449_200x150.jpg"
#   a.asset_large_thumbnail_url = "http:\/\/i.vimeocdn.com\/video\/482623449_640.jpg"
# end
# puts "digital asset: " << asset.asset_name
# asset.save

# asset = DigitalAsset.find_or_create_by(:asset_name => "Chants of Krishna part 3").tap do |a|
#   a.asset_description = "Sacred chants of Krishna Part 3"
#   a.asset_type = "vimeo_video"
#   a.video_id = "100967800"
#   a.price = 1
#   a.allowable_promo_code = "[\"om namo bhagavate vasudevaya\"]"
#   a.asset_vimeo_embed_link = "<iframe src=\"//player.vimeo.com/video/100967800\" width=\"500\" height=\"281\" frameborder=\"0\" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>"
#   a.asset_list_thumbnail_url ="http:\/\/i.vimeocdn.com\/video\/482622377_200x150.jpg"
#   a.asset_large_thumbnail_url = "http:\/\/i.vimeocdn.com\/video\/482622377_640.jpg"
# end
# puts "digital asset: " << asset.asset_name
# puts " has id " << asset.video_id
# asset.save

# asset = DigitalAsset.find_or_create_by(:asset_name => "Chants of Krishna part 4").tap do |a|
#   a.asset_description = "Sacred chants of Krishna part 4"
#   a.asset_type = "vimeo_video"
#   a.video_id = "100967798"
#   a.price = 1
#   a.allowable_promo_code = "[\"om namo bhagavate vasudevaya\"]"
#   a.asset_vimeo_embed_link = '<iframe src="//player.vimeo.com/video/100967798" width="500" height="281" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>'
#   a.asset_list_thumbnail_url = "http:\/\/i.vimeocdn.com\/video\/482622381_200x150.jpg"
#   a.asset_large_thumbnail_url = "http:\/\/i.vimeocdn.com\/video\/482622381_640.jpg"
# end
# puts "digital asset: " << asset.asset_name
# asset.save

# asset = DigitalAsset.find_or_create_by(:asset_name => "Chants of Krishna part 5").tap do |a|
#   a.asset_description = "Sacred chants of Krishna"
#   a.asset_type = "vimeo_video"
#   a.video_id = "100967801"
#   a.price = 1
#   a.allowable_promo_code = "[\"om namo bhagavate vasudevaya\"]"
#   a.asset_vimeo_embed_link = '<iframe src="//player.vimeo.com/video/100967801?title=0&amp;byline=0&amp;portrait=0&amp;color=ff9933" width="500" height="281" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>'
#   a.asset_list_thumbnail_url = "http:\/\/i.vimeocdn.com\/video\/482622383_200x150.jpg"
#   a.asset_large_thumbnail_url = "http:\/\/i.vimeocdn.com\/video\/482622383_640.jpg"
# end
# puts "digital asset: " << asset.asset_name
# asset.save

# collection = Collection.find_or_create_by(:collection_name => 'Sacred Chants of Krishna Collection').tap do |a|
#   a.collection_thumbnail_url = 'http:\/\/i.vimeocdn.com\/video\/482622383_200x150.jpg'
#   a.collection_description = 'All videos for Chants of Krishna are part of this collection'
# end
# puts "collection: " << collection.collection_name

# collection.digital_assets << DigitalAsset.find_by(asset_name: "Chants of Krishna part 1");
# collection.digital_assets << DigitalAsset.find_by(asset_name: "Chants of Krishna part 2");
# collection.digital_assets << DigitalAsset.find_by(asset_name: "Chants of Krishna part 3");
# collection.digital_assets << DigitalAsset.find_by(asset_name: "Chants of Krishna part 4");
# collection.digital_assets << DigitalAsset.find_by(asset_name: "Chants of Krishna part 5");
# collection.save

# asset = DigitalAsset.find_or_create_by(:asset_name => 'Chants of Krishna collection');
# asset.asset_collection = collection
# asset.asset_list_thumbnail_url = "http:\/\/i.vimeocdn.com\/video\/482622383_200x150.jpg"
# asset.asset_large_thumbnail_url = "http:\/\/i.vimeocdn.com\/video\/482622383_640.jpg"
# asset.is_collection = true
# asset.price = 4
# asset.save
# puts "digital asset: " << asset.asset_name

# ["Accounting", "Administration &amp; Office Support", "Advertising, Arts & Media", "Agriculture, Animals & Conservation", "Banking & Financial Services", "Call Centre & Customer Services", "CEO & General Management", "Community Services & Development", "Construction", "Consulting & Strategy", "Defense", "Design & Architecture", "Doctor", "Education & Training", "Engineering",     "Government", "Healthcare & Medical", "Homemaker", "Hospitality & Tourism", "Human Resources & Recruitment", "Information & Communication Technology", "Insurance & Superannuation",         "Legal", "Manufacturing", "Marketing & Communications", "Mining, Resources & Energy", "Real Estate & Property", "Retail & Consumer Products", "Retired", "Sales", "Science & Technology", "Self         Employed", "Sports & Recreation", "Student", "Trades & Services", "Transport & Logistics", "Unemployed", "Others"].each do |profession_name|
#       Profession.find_or_create_by(name: profession_name)
#     end
#     profession = Profession.find_or_create_by(:name => "Doctor")
#     profession.code = "doctor"
#     profession.save!
#     puts 'profession: ' << profession.code
#     puts "All seeds successfully run!"

#     ["Nachiketa Agni Dhyaan", "Siddha Self Healing", "Advait Shree Vidya", "Clairvoyance Siddha Scanning", "Prati Prasav Sadhna", "Shambhavi Healing", "Crystal Healing", "Shiv Swadhyay" ].each do |frequent_sadhana_type|
#       FrequentSadhnaType.find_or_create_by(name: frequent_sadhana_type)
#     end

#     ["Unconditional love", "Be a Role Model", "Respect for All", "Forgiveness Nishkaam Sewa", "Sankirtan", "Acceptance", "Humility", "Self Analysis", "Nishkaam Saadhna", "Let Go (Drishta Bhaav)" ].each do |shivyog_teaching|
#       ShivyogTeaching.find_or_create_by(name: shivyog_teaching)
#     end

#     ["Yoga", "Pranayam", "Brisk Walking", "Surya Namaskaar", "Jogging", "Sarp Kriyas", "Praan Kriyas", "Shankh Prakshaalan
#     " ].each do |physical_exercise_type|
#       PhysicalExerciseType.find_or_create_by(name: physical_exercise_type)
#     end

#     ["Service tax", "Service charge", "VAT"].each do |tax_type|
#       TaxType.find_or_create_by(name: tax_type)
#     end
#     EventType.find_or_create_by(name: 'dss')
#     ["Hall", "Open Ground", "Marquee", "House" ].each do |venue_type|
#       VenueType.find_or_create_by(name: venue_type)
#     end
    # CannonicalEvent.where(event_meta_type: 'physical').update_all(event_meta_type: 'mega')
    # PgSyddMerchant.find_or_create_by(name: 'Delhi aashram', sms_enabled:true, sms_limit: 120, public_key: 'test', private_key: 'test', domain: 'test', email: 'syit.namahshivay@gmail.com')
    # PaymentGatewayType.find_or_create_by(name: 'ccavenue', config_model_name: "CcavenueConfig", relation_name: "ccavenue_config")
    # PaymentGateway.find_or_create_by(payment_gateway_type_id: 4)
    # CcavenueConfig.find_or_create_by(payment_gateway_id: 4, alias_name: 'ccavenue1', merchant_id: '2667', access_code: 'AVJJ04CB62CG85JJGC', working_key: '2193D65D10409D3391BAA935FC9E3C13')
#     PaymentGatewayType.find_or_create_by(name: 'sydd', config_model_name: "PgSyddConfig", relation_name: "pg_sydd_config")
# PgSyddConfig.find_or_create_by(public_key: 'test', private_key: 'test', pg_sydd_merchant_id: 1)
# [" Certified Nurse Midwife", "Certified Registered Nurse Anesthetist", "Clinical Nurse Specialist", "Nurse Practitioner", "Physician Assistant","Registered Nurse", "Pharmacy", "Optometry", "EMT / Paramedic", "Diet / Nutrition", "Sonography", "Nuclear Medicine Technician", "Occupational Health and Safety Technician", "Radiology Technician", "Surgical Technician", "Occupational Technician", "Physical Therapy", "Molecular Biology", "Ayurveda", "Acupressure", "Acupuncture", "Homoeopathy", "RMP", "Dentistry",
#   "Allergy (immunologist)", "Anesthesiology", "Cardiac Electrophysiology", "Cardiology", "Cardiovascular Surgery", "Chiropractic", "Colon and Rectal Surgery", "Critical Care Medicine", "Dermatology", "Pediatrics", "Emergency Medicine", "Endocrinology", "Family Medicine", "Forensic Pathology", "Gastroenterology",
#     "Geriatric Medicine", "Gynecology", "Hand Surgery", "Hematology", "Hepatology", "Hospice and Palliative Medicine", "Infectious Disease", "Internal Medicine", "Interventional Cardiology", "Medical Examiner", "Genetics", "Neonatology", "Nephrology", "Neurological Surgery", 'Neurology', "Nuclear Medicine", "Occupational", "Medicine", "Oncology", "Ophthalmology", "Oral Surgery (maxillofacial surgeon)", "Orthopedic Surgery", "Orthodontic", "ENT", "Pain Management", "Pathology", "Perinatology", "Physiatry", "Plastic Surgery", "Podiatry", "Psychiatry", "Pulmonology", "Radiation Oncology", "Radiology"," Reproductive Endocrinology", "Rheumatology", "Sleep Disorder", "Sports Medicine", "Thoracic Surgery", "Urology", "Vascular Surgery", "Clinical Nurse Specialist", "Nurse Practitioner",
#       "Physical Therapy", "Counseling", "Physiotherapy", "Others"].each do |speciality_area|
#     MedicalPractitionerSpecialityArea.find_or_create_by(name: speciality_area)
#     end

#     photoIdProofs = ["Pan Card","Passport","Voter Id","Aadhar Card","Driving License","Health Card","Govts Issued Id Card","Other"]
#     addressProofs = ["Ration Card", "Telephone Bill","Credit Card Bill","Driving Licesne","Passport", "Electricity Bill","Gas Connection Bill","Aadhar Card","Bank Passbook"]

#     addressProofs.each do |apt|
#         AddressProofType.find_or_create_by(name: apt)
#     end

#     photoIdProofs.each do |ppt|
#         PhotoIdType.find_or_create_by(name: ppt)
#     end

#     payment_gateway_types = [{
#         name: 'razorpay',
#         config_model_name: 'PgSyRazorpayConfig',
#         relation_name: 'pg_sy_razorpay_config'
#     }, {
#         name: 'braintree',
#         config_model_name: 'PgSyBraintreeConfig',
#         relation_name: 'pg_sy_braintree_config'
#     }, {
#         name: 'paypal',
#         config_model_name: 'PgSyPaypalConfig',
#         relation_name: 'pg_sy_paypal_config'
#     }]

#         payment_gateway_types.each do |pgt|
#             PaymentGatewayType.find_or_create_by(name: pgt[:name], config_model_name: pgt[:config_model_name], relation_name: pgt[:relation_name])
#         end

#     ["President", "Vice-President", "Secretary"].each do |role|
#         SyClubUserRole.find_or_create_by(role_name: role)
#     end

#     ["forum"].each do |widget|
#         DashboardWidgetConfig.find_or_create_by(widget: widget)
#     end
# ['Text Box', 'Single Select', 'Multi Select', 'Text Area', 'Check Box'].each do |v|
#     a = SyFormFieldType.find_or_create_by(name: v.to_s)
#     puts a
# end
	# other_state = DbState.find_or_create_by(id: 99999, name: 'Others')
	# puts other_state

	# other_city = DbCity.find_or_create_by(id: 999999, name: 'Others')
	# puts other_city

	# global_preference = GlobalPreference.find_or_create_by(key: 'email', alias_name: 'Event Summay Report')

	# PaymentGatewayType.find_or_create_by(config_model_name: "PgSyPayfastConfig", name: "payfast", relation_name: "pg_sy_payfast_config")

  # GlobalPreference.find_or_create_by(key: 'global_clp_renewal_link', alias_name: 'Global CLP Renewal Link')
  # GlobalPreference.find_or_create_by(key: 'india_clp_renewal_link', alias_name: 'India CLP Renewal Link')
  # GlobalPreference.find_or_create_by(key: 'global_clp_validity', alias_name: 'Global CLP Validity in Days')
  # GlobalPreference.find_or_create_by(key: 'india_clp_validity', alias_name: 'India CLP Validity in Days')
  #
  # ["TV", "Website", "Social media", "Others"].each do |source|
		# SourceInfoType.find_or_create_by(source_name: source)
  # end
  #
  # sub_source = {}
  # sub_source["tv"] = ["Aastha", "Sanskar", "Disha", "Zee TV", "Asia TV", "MAA TV", "State Channel", "Cable Channel"]
  # sub_source["website"] = ["shivyog.com", "sciencebeyondscience.org", "fromthemaster.com", "universaldivineshop.com", "shivyogforum.com"]
  # sub_source["social media"] = ["Facebook", "Twitter", "Instagram"]
  # sub_source["others"] = ["Word of Mouth", "Flyer", "Banner", "WhatsApp", "SMS", "Mass Mailer", "Any Other"]
  #
  # SourceInfoType.all.each do |source|
		# (sub_source["#{source.source_name.try(:downcase).to_s}"] || []).each do |sub_source|
		# 	SubSourceType.find_or_create_by(sub_source_name: sub_source, source_info_type_id: source.id)
		# end
  # end
  #
  # GlobalPreference.find_or_create_by(key: 'india_forum_summary_emails', alias_name: 'India Forum Summary Report')
  # GlobalPreference.find_or_create_by(key: 'global_forum_summary_emails', alias_name: 'Global Forum Summary Report')

	# [546, 547, 548, 549, 550, 551, 552, 553, 554, 555, 556, 557, 562, 563, 564, 565, 566, 567, 569, 570, 571, 572, 573, 576, 577, 578, 579, 581, 582, 584, 585, 588, 589, 590, 592, 593, 594, 595, 597, 598, 600, 603, 604, 607, 613, 617].each do |event_id|
	# 	EventGiftLog.find_or_create_by(event_id: event_id, message: 'Sent on 12 May 2016.', status: EventGiftLog.statuses['done'])
	# end


	# # Create event reistration report
	# event_registration_report_master = ReportMaster.find_or_create_by(report_name: 'event_registration', required_params: ['event_id'])
  #
  # # Create Tally Report
  # event_registration_tally_report_master = ReportMaster.find_or_create_by(report_name: 'event_registration_tally', required_params: ['event_id'])
  #
	# columns1 = %w(REGISTRATION_NUMBER OLD_SYID OLD_FIRST_NAME OLD_LAST_NAME NEW_SYID NEW_FIRST_NAME NEW_LAST_NAME NAME_CHANGED_DATE NEW_MOBILE NEW_EMAIL NEW_COUNTRY NEW_STATE NEW_CITY NEW_STREET_ADDRESS OLD_TRANSACTION_ID NEW_TRANSACTION_ID DATE_OF_TRANSACTION OLD_SEATING_CATEGORY NEW_SEATING_CATEGORY OLD_CATEGORY_AMOUNT NEW_CATEGORY_AMOUNT OLD_DISCOUNT NEW_DISCOUNT DIFFERENCE_AMOUNT(PAID/REFUNDED) TOTAL_TAX CONVIENENCE_CHARGES TOTAL_PAID REGISTRATION_STATUS REG_REF_NUMBER REGISTRATION_DATE EVENT_NAME EVENT_START_DATE EVENT_END_DATE PAYMENT_STATUS PAYMENT_METHOD REGISTRATION_ID ITEM_ID FORUM_ID FORUM_NAME MEDICAL_DEGREE CURRENT_PROFESSION WORK_ENVIRONMENT SPECIALITY_AREA BANK_NAME ADMIN_NOTES DD_DATE REGISTERED_BY)
  #
	# columns1.each do |c|
	# 	rmf = ReportMasterField.find_or_create_by(field_name: c.downcase)
	# 	ReportMasterFieldAssociation.find_or_create_by(report_master_id: event_registration_report_master.id, report_master_field_id: rmf.id)
	# end
  #
	# event_registration_report_master.reload.update_report_blocks
  #
  # # Tally Report columns insertion
  # columns2 = %w(REGISTRATION_NUMBER SYID NAME CATEGORY REGISTRATION_DATE AMOUNT TOTAL_TAX GRAND_TOTAL TRANSACTION_ID COST_CENTER_NAME)
  #
	# columns2.each do |c|
	# 	rmf = ReportMasterField.find_or_create_by(field_name: c.downcase)
	# 	ReportMasterFieldAssociation.find_or_create_by(report_master_id: event_registration_tally_report_master.id, report_master_field_id: rmf.id)
	# end
  #
	# event_registration_tally_report_master.reload.update_report_blocks


  # event_registration_dd_cash_tally_report_master = ReportMaster.find_or_create_by(report_name: 'event_registration_dd_cash_tally', required_params: ['event_id'])
  #
  # columns = %w(registration_number syid name registration_date amount total_tax grand_total payment_type dd_number dd_date cost_center_name)
  #
  # columns.each do |c|
  #   rmf = ReportMasterField.find_or_create_by(field_name: c.downcase)
  #   ReportMasterFieldAssociation.find_or_create_by(report_master_id: event_registration_dd_cash_tally_report_master.id, report_master_field_id: rmf.id)
  # end
  #
  # event_registration_dd_cash_tally_report_master.reload.update_report_blocks

  # Added two more columns in event_registration_report
  # event_registration_report_master = ReportMaster.find_by(report_name: 'event_registration')
  #
  # columns = %w(new_gender new_date_of_birth)
  #
  # columns.each do |c|
  #   rmf = ReportMasterField.find_or_create_by(field_name: c.downcase)
  #   ReportMasterFieldAssociation.find_or_create_by(report_master_id: event_registration_report_master.id, report_master_field_id: rmf.id)
  # end
  #
  # event_registration_report_master.reload.update_report_blocks


  # Added two more columns in event_registration_report
  # event_registration_report_master = ReportMaster.find_by(report_name: 'event_registration')
  #
  # columns = %w(photo_id_uploaded photo_id_approved photo_id_proof_uploaded photo_id_proof_approved photo_id_proof_number address_proof_uploaded address_proof_approved)
  #
  # columns.each do |c|
  #   rmf = ReportMasterField.find_or_create_by(field_name: c.downcase)
  #   ReportMasterFieldAssociation.find_or_create_by(report_master_id: event_registration_report_master.id, report_master_field_id: rmf.id)
  # end
  #
  # event_registration_report_master.reload.update_report_blocks

  # event_registration_report_master = ReportMaster.find_by(report_name: 'event_registration')

  # columns = %w(photo_id_last_updated photo_id_proof_last_updated)

  # columns.each do |c|
  #   rmf = ReportMasterField.find_or_create_by(field_name: c.downcase)
  #   ReportMasterFieldAssociation.find_or_create_by(report_master_id: event_registration_report_master.id, report_master_field_id: rmf.id)
  # end

  # event_registration_report_master.reload.update_report_blocks


  # Create entries in global preferences.

  gp = GlobalPreference.find_or_create_by(key: 'photo_and_photo_id_approval_email_text', alias_name: 'Sadhak Profile photo and photo id approval email text')

  gp.update(val: 'We wish to inform you that your photo and photo ID has been approved. In case you applied for any shivir please login to your SYID profile and download your entry card.')

  # 'We wish to inform you that your photo and photo ID has been approved. In case you applied for any shivir please login to your SYID profile and download your entry card.'

  gp = GlobalPreference.find_or_create_by(key: 'photo_and_photo_id_approval_sms_text', alias_name: 'Sadhak Profile photo and photo id approval sms text')

  gp.update(val: 'We wish to inform you that your photo and photo ID has been approved. In case you applied for any shivir please login to your SYID profile and download your entry card.')

  # 'We wish to inform you that your photo and photo ID has been approved. In case you applied for any shivir please login to your SYID profile and download your entry card.'

  gp = GlobalPreference.find_or_create_by(key: 'photo_and_photo_id_rejection_email_text', alias_name: 'Sadhak Profile photo and photo id rejection email text')

  gp.update(val: 'Your Photo or Photo ID is rejected. Please make sure to upload correct and clear photo and photo ID. Please make sure that picture of your face is clearly visible in your photo.')

  # 'Your Photo or Photo ID is rejected. Please make sure to upload correct and clear photo and photo ID. Please make sure that picture of your face is clearly visible in your photo.'

  gp = GlobalPreference.find_or_create_by(key: 'photo_and_photo_id_rejection_sms_text', alias_name: 'Sadhak Profile photo and photo id rejection sms text')

  gp.update(val: 'Your Photo or Photo ID is rejected. Please make sure to upload correct and clear photo and photo ID. Please make sure that picture of your face is clearly visible in your photo.')

  # 'Your Photo or Photo ID is rejected. Please make sure to upload correct and clear photo and photo ID. Please make sure that picture of your face is clearly visible in your photo.'

  gp = GlobalPreference.find_or_create_by(key: 'photo_and_photo_id_rejection_reasons', alias_name: 'Sadhak Profile photo and photo id rejection reasons')

  gp.update(val: 'Profile photo is not clear, Photo id proof is not clear, Profile photo and photo id both are not clear')
  # 'Profile photo is not clear, Photo id proof is not clear, Profile photo and photo id both are not clear'

  # Create Photo approval report excel
  photo_approval_report_master = ReportMaster.find_or_create_by(report_name: 'photo_approval', required_params: ['report_master_id'])

  # Create Photo approval report excel
  columns1 = %w(SYID NAME PHOTO PHOTO_ID APPROVAL_STATUS APPROVED_BY_SYID APPROVED_BY_NAME)

  columns1.each do |c|
    rmf = ReportMasterField.find_or_create_by(field_name: c.downcase)
    ReportMasterFieldAssociation.find_or_create_by(report_master_id: photo_approval_report_master.id, report_master_field_id: rmf.id)
  end

  photo_approval_report_master.reload.update_report_blocks

  # Roles and Associations
  # ["id", "name", "description", "expiry", "created_at", "updated_at", "deleted_at", "whodunnit", "type"]

  $current_user = User.find(Rails.env.development? ? 2 : Rails.env.staging? ? 64 : 122)

  [{name: 'super_admin', description: 'Shivyog Site Admin.', role_type: 'independent'}, {name: 'event_admin', description: 'Shivyog Event(s) Admin.', role_type: 'independent'}, {name: 'photo_approval_admin', description: 'Shivyog Photo Approval Admin.', role_type: 'independent'}, {name: 'admin', description: 'Shivyog Admin(s).', role_type: 'dependent'}, {name: 'photo_approval_user', description: 'Photo Approval User.', role_type: 'dependent'}].each do |role_attributes|

    role = Role.find_by_name(role_attributes[:name])

    if role.present?
      role.update(role_attributes)
    else
      Role.create!(role_attributes)
    end

  end




