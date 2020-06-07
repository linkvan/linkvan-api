# rubocop:disable Metrics/BlockLength

require 'rails_helper'

RSpec.describe Api::FacilitiesController do
  let(:test_services) { 'Test AnotherTest Yet_Another_Test' }
  # let(:all_day_facility) { create(:open_all_day_facility, services: test_services) }
  # let(:always_closed_facility) { create(:close_all_day_facility) }
  # let(:now_open_facility) { create(:open_facility) }
  # let(:now_open2_facility) { create(:open2_facility) }

  describe "GET #index" do
    before do
      @all_day_facility = create(:open_all_day_facility, services: test_services)
      get :index
    end

    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end

    describe "JSON body response" do
      let(:json_response) { JSON.parse(response.body).with_indifferent_access }

      it "contains expected keys" do
        # json_response = JSON.parse(response.body)
        expect(json_response.keys).to match_array(%w[status facilities])
      end

      it "contains a facilities list" do
        # expected_columns = [:id, :name, :phone, :services, :lat, :long, :schedule]
        # json_response = JSON.parse(response.body)
        # puts "Hash: #{json_response['facilities'].class.name}"
        expect(json_response['facilities']).to be_a(Array)
      end

      # Facility objects description
      describe "facilities key" do
        let(:returned_facilities) { json_response[:facilities].first }

        # list of attributes:
        # facility_attribs = %w[id name welcomes services lat long address phone website description notes verified shelter_note food_note medical_note hygiene_note technology_note legal_note learning_note zone_id created_at updated_at]
        # facility_attibs_removed = %w[r_pets r_id r_cart r_phone r_wifi]
        # facility_attribs = %w[id name phone services lat long]
        # facility_attibs_removed = %w[welcomes address website description notes verified shelter_note food_note medical_note hygiene_note technology_note legal_note learning_note zone_id created_at updated_at r_pets r_id r_cart r_phone r_wifi user_id]

        # # All included Facility atributes
        # describe "contains" do
        #   facility_attribs.each do |field|
        #     it "#{field} field" do
        #       expect(returned_facilities.keys).to include(field.to_s)
        #     end
        #   end
        # end

        # # All non-included Facility atributes
        # describe "doesn't contain" do
        #   facility_attibs_removed.each do |field|
        #     it "#{field} field" do
        #       expect(returned_facilities.keys).not_to include(field.to_s)
        #     end
        #   end
        # end

        # # Facility services field description
        # describe "contains services object which" do
        #   let(:facility_services) { returned_facilities['services'] }
        #   it 'has a list' do
        #     expect(facility_services).to be_a(Array)
        #   end
        #   it 'lists underscored strings' do
        #     # Test AnotherTest Yet_Another_Test
        #     expect(facility_services).to include('test')
        #     expect(facility_services).to include('another_test')
        #     expect(facility_services).to include('yet_another_test')
        #   end
        # end #/services

        # # Facility schedule field description
        # describe "contains schedule object which" do
        #   it 'has schedule field' do
        #     # puts "Response: #{returned_facilities}"
        #     expect(returned_facilities.keys).to include('schedule')
        #   end

        #   # Included fields of schedule object
        #   expected_schedule_fields = %w[schedule_sunday schedule_monday schedule_tuesday schedule_wednesday schedule_thursday schedule_friday schedule_saturday]
          
        #   it 'has schedule for every days of week' do
        #     expect(returned_facilities[:schedule].keys).to match_array(expected_schedule_fields)
        #   end

        #   expected_schedule_fields.each do |field|
        #     describe "contains #{field} object which" do
        #       let(:schedule_field) { returned_facilities.dig('schedule', field) }

        #       it "has availabity field" do
        #         expect(schedule_field.keys).to include('availability')
        #       end

        #       it "has times field" do
        #         expect(schedule_field.keys).to include('times')
        #       end
        #     end
        #   end #/schedule_fields
        # end #/schedule
        
      end #/facilities
    end #/json body
  end #/index
end

# //GET linkvan.ca/facilities?type=shelter&q=asdf
# {
#   "facilities": [
#     {
#       "id": 1,
#       "name": "Andre",
#       "phone": "8888888",
#       "services": %w[shelter asd_asd],
#       "lat": 400000,
#       "long": 400000,
#       "schedule": {
#         "schedule_monday": {
#           "availability": "set_time",
#           "time": [
#             {
#               "from_hour": "09",
#               "from_min": "30",
#               "to_hour": "17",
#               "to_min": "30"
#             }
#           ]
#         },
#         "schedule_tuesday": {
#           "availability": "open"
#         },
#         "schedule_wednesday": {
#           "availability": "closed"
#         },
#         "schedule_thursday": {
#           "availability": "open"
#         },
#         "schedule_friday": {
#           "availability": "open"
#         },
#         "schedule_saturday": {
#           "availability": "open"
#         },
#         "schedule_sunday": {
#           "availability": "open"
#         }
#       }
#     }
#   ]
# }
