class Notice < ApplicationRecord
  enum notice_type: {
     general: "general",
     covid19: "covid19",
     warming_center: "warming_center",
     cooling_center: "cooling_center"
   }

  scope :published, -> { where(published: true) }
end
