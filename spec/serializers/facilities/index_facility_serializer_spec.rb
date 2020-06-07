require 'rails_helper'

describe Facilities::IndexFacilitySerializer do
  let(:test_services) { 'Test AnotherTest Yet_Another_Test' }
  let(:all_day_facility) { create(:open_all_day_facility, services: test_services) }
  let(:always_closed_facility) { create(:close_all_day_facility) }
  let(:now_open_facility) { create(:open_facility) }
  let(:now_open2_facility) { create(:open2_facility) }

  describe 'as_json hash' do
    let(:serializer_class) { Facilities::IndexFacilitySerializer }
    let(:all_day_serializer) { serializer_class.new(all_day_facility) }
    let(:serialized_all_day_facility) { all_day_serializer.as_json }

    subject { all_day_serializer.as_json }

    facility_attribs = %w[id name phone services lat long schedule]
    facility_attibs_removed = %w[welcomes address website description notes verified shelter_note food_note medical_note hygiene_note technology_note legal_note learning_note zone_id created_at updated_at r_pets r_id r_cart r_phone r_wifi user_id]

    # All included Facility atributes
    facility_attribs.each do |field|
      it { should include(field) }
    end

    # All non-included Facility atributes
    facility_attibs_removed.each do |field|
      it { should_not include(field) }
    end

    # Facility services field content
    describe "services" do
      subject { serialized_all_day_facility['services'] }

      it { should include('test') }
      it { should include('another_test') }
      it { should include('yet_another_test') }
    end #/services

    # Facility schedule field content
    describe "schedule" do
      subject { serialized_all_day_facility['schedule'] }

      # All schedule fields
      expected_schedule_fields = %w[schedule_sunday schedule_monday schedule_tuesday schedule_wednesday schedule_thursday schedule_friday schedule_saturday]
      expected_schedule_fields.each do |field|
        it { should include(field) }
        it { should be_a(Hash) }

        describe field.to_s do
          subject { serialized_all_day_facility.dig('schedule', 'schedule_sunday') }
          it { should include(:availability) }
          it { should include(:times) }
        end
      end

      describe 'for open all day facilities' do
        let(:all_open_sunday_schedule) { serialized_all_day_facility.dig('schedule', 'schedule_sunday') }

        describe "availability" do
          subject { all_open_sunday_schedule['availability'] }
          it { should eq('open') }
        end
        
        describe 'times' do
          subject { all_open_sunday_schedule['times'] }
          it { should be_a(Array) }
          it { should be_empty }
        end
      end #/all day open

      describe 'for now open facilities' do
        let(:serialized_facility) { serializer_class.new(now_open_facility).as_json }
        let(:now_open_schedule) { serialized_facility.dig('schedule', 'schedule_sunday') }

        describe "availability field" do
          subject { now_open_schedule['availability'] }
          it { should eq('set_times') }
        end

        # describe 'times' do
        describe 'times field' do
          subject { now_open_schedule['times'] }
          it { should be_a(Array) }
          it { should_not be_empty }
          describe 'size' do
            it { expect(subject.size).to eq(1) }
          end
          
          describe 'times object' do
            subject { now_open_schedule['times'].first }
            it { should include(from_hour: 2.hours.ago.hour.to_s) }
            it { should include(from_min: 2.hours.ago.min.to_s) }
            it { should include(to_hour: 2.hours.from_now.hour.to_s) }
            it { should include(to_min: 2.hours.from_now.min.to_s) }
          end
        end #/times
        
      end #/now open
    end #/schedule
  end
end
