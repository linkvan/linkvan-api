require 'rails_helper'

describe Facilities::IndexFacilitySerializer do
  let(:test_services) { 'Test AnotherTest Yet_Another_Test' }
  let(:all_day_facility) { create(:open_all_day_facility, services: test_services) }
  let(:always_closed_facility) { create(:close_all_day_facility) }
  let(:now_open_facility) { create(:open_facility) }
  let(:now_open2_facility) { create(:open2_facility) }

  describe 'as_json hash' do
    subject { all_day_serializer.as_json }

    let(:serializer_class) { Facilities::IndexFacilitySerializer }
    let(:all_day_serializer) { serializer_class.new(all_day_facility) }
    let(:serialized_all_day_facility) { all_day_serializer.as_json }

    facility_attribs = %w[id name phone services lat long schedule]
    facility_attibs_removed = %w[welcomes address website description notes verified shelter_note food_note medical_note hygiene_note technology_note legal_note learning_note zone_id created_at updated_at r_pets r_id r_cart r_phone r_wifi user_id]

    # All included Facility atributes
    facility_attribs.each do |field|
      it { is_expected.to include(field) }
    end

    # All non-included Facility atributes
    facility_attibs_removed.each do |field|
      it { is_expected.not_to include(field) }
    end

    # Facility services field content
    describe "services" do
      subject { serialized_all_day_facility['services'] }

      it { is_expected.to include('test') }
      it { is_expected.to include('another_test') }
      it { is_expected.to include('yet_another_test') }
    end #/services

    # Facility schedule field content
    describe "schedule" do
      subject { serialized_all_day_facility['schedule'] }

      # All schedule fields
      expected_schedule_fields = %w[schedule_sunday schedule_monday schedule_tuesday schedule_wednesday schedule_thursday schedule_friday schedule_saturday]
      expected_schedule_fields.each do |field|
        it { is_expected.to include(field) }
        it { is_expected.to be_a(Hash) }

        describe field.to_s do
          subject { serialized_all_day_facility.dig('schedule', 'schedule_sunday') }

          it { is_expected.to include(:availability) }
          it { is_expected.to include(:times) }
        end
      end

      describe 'for open all day facilities' do
        let(:all_open_sunday_schedule) { serialized_all_day_facility.dig('schedule', 'schedule_sunday') }

        describe "availability" do
          subject { all_open_sunday_schedule['availability'] }

          it { is_expected.to eq('open') }
        end
        
        describe 'times' do
          subject { all_open_sunday_schedule['times'] }

          it { is_expected.to be_a(Array) }
          it { is_expected.to be_empty }
        end
      end #/all day open

      describe 'for now open facilities' do
        let(:serialized_facility) { serializer_class.new(now_open_facility).as_json }
        let(:now_open_schedule) { serialized_facility.dig('schedule', 'schedule_sunday') }

        describe "availability field" do
          subject { now_open_schedule['availability'] }

          it { is_expected.to eq('set_times') }
        end

        # describe 'times' do
        describe 'times field' do
          subject { now_open_schedule['times'] }

          it { is_expected.to be_a(Array) }
          it { is_expected.not_to be_empty }

          describe 'size' do
            it { expect(subject.size).to eq(1) }
          end
          
          describe 'times object' do
            subject { now_open_schedule['times'].first }

            let(:time_from_now) { 2.hours.from_now.to_s(:time).split(':') }
            let(:time_ago) { 2.hours.ago.to_s(:time).split(':') }

            it { is_expected.to include(from_hour: time_ago[0]) }
            it { is_expected.to include(from_min: time_ago[1]) }
            it { is_expected.to include(to_hour: time_from_now[0]) }
            it { is_expected.to include(to_min: time_from_now[1]) }
          end
        end #/times
        
      end #/now open
    end #/schedule
  end
end
