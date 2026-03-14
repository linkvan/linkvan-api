# frozen_string_literal: true

# rubocop:disable RSpec/MultipleDescribes
require "rails_helper"

RSpec.describe Admin::FacilitySchedulesController do
  let(:admin_user) { create(:user, :admin, :verified) }
  let(:facility) { create(:facility) }

  # Stub Devise authentication methods
  before do
    allow(controller).to receive_messages(authenticate_user!: true, current_user: admin_user, user_signed_in?: true)
  end

  describe "POST #create" do
    it "creates a schedule" do
      expect do
        post :create, params: { facility_id: facility.id, schedule: { week_day: :tuesday, closed_all_day: true } }
      end.to change(FacilitySchedule, :count).by(1)
    end

    it "redirects" do
      post :create, params: { facility_id: facility.id, schedule: { week_day: :tuesday, closed_all_day: true } }
      expect(response).to redirect_to(admin_facility_path(id: facility.id))
    end
  end

  describe "PATCH #update" do
    let(:schedule) { create(:facility_schedule, facility: facility, week_day: :friday, closed_all_day: true) }

    it "updates schedule" do
      patch :update, params: { facility_id: facility.id, id: schedule.id, schedule: { open_all_day: true } }
      expect(schedule.reload).to be_open_all_day
    end

    it "redirects" do
      patch :update, params: { facility_id: facility.id, id: schedule.id, schedule: { open_all_day: true } }
      expect(response).to redirect_to(admin_facility_path(id: facility.id))
    end
  end
end

RSpec.describe Admin::FacilityServicesController do
  let(:admin_user) { create(:user, :admin, :verified) }
  let(:facility) { create(:facility) }
  let(:service) { create(:service, name: "Water Fountain", key: "water_fountain") }

  # Stub Devise authentication methods
  before do
    allow(controller).to receive_messages(authenticate_user!: true, current_user: admin_user, user_signed_in?: true)
  end

  describe "POST #create" do
    it "creates a facility service" do
      expect do
        post :create, params: { facility_id: facility.id, service_id: service.id }
      end.to change(FacilityService, :count).by(1)
    end

    it "redirects" do
      post :create, params: { facility_id: facility.id, service_id: service.id }
      expect(response).to redirect_to(admin_facility_path(id: facility.id))
    end
  end

  describe "PATCH #update" do
    let(:facility_service) { create(:facility_service, facility: facility, service: service, note: nil) }

    it "updates note" do
      patch :update, params: { facility_id: facility.id, id: facility_service.id, service_id: service.id, facility_service: { note: "Updated note" } }
      expect(facility_service.reload.note).to eq("Updated note")
    end
  end

  describe "DELETE #destroy" do
    let(:facility_service) { create(:facility_service, facility: facility, service: service) }

    it "destroys facility service" do
      # The record is destroyed, so trying to reload it raises RecordNotFound
      delete :destroy, params: { facility_id: facility.id, id: facility_service.id, service_id: service.id }
      expect { facility_service.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "redirects" do
      delete :destroy, params: { facility_id: facility.id, id: facility_service.id, service_id: service.id }
      expect(response).to redirect_to(admin_facility_path(id: facility.id))
    end

    it "sets flash notice" do
      delete :destroy, params: { facility_id: facility.id, id: facility_service.id, service_id: service.id }
      expect(flash[:notice]).to match(/Successfully turned off.*service/)
    end
  end
end

RSpec.describe Admin::FacilityWelcomesController do
  let(:admin_user) { create(:user, :admin, :verified) }
  let(:facility) { create(:facility) }

  # Stub Devise authentication methods
  before do
    allow(controller).to receive_messages(authenticate_user!: true, current_user: admin_user, user_signed_in?: true)
  end

  describe "POST #create" do
    it "creates a facility welcome" do
      expect do
        post :create, params: { facility_id: facility.id, customer: :male }
      end.to change(FacilityWelcome, :count).by(1)
    end

    it "redirects" do
      post :create, params: { facility_id: facility.id, customer: :male }
      expect(response).to redirect_to(admin_facility_path(id: facility.id))
    end
  end

  describe "DELETE #destroy" do
    let(:facility_welcome) { create(:facility_welcome, facility: facility, customer: :male) }

    it "destroys facility welcome" do
      # The record is destroyed, so trying to reload it raises RecordNotFound
      delete :destroy, params: { facility_id: facility.id, id: facility_welcome.id }
      expect { facility_welcome.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "redirects" do
      delete :destroy, params: { facility_id: facility.id, id: facility_welcome.id }
      expect(response).to redirect_to(admin_facility_path(id: facility.id))
    end

    it "sets flash notice" do
      delete :destroy, params: { facility_id: facility.id, id: facility_welcome.id }
      expect(flash[:notice]).to match(/Successfully turned off.*welcome/)
    end
  end
end

RSpec.describe Admin::FacilityTimeSlotsController do
  let(:admin_user) { create(:user, :admin, :verified) }
  let(:facility) { create(:facility) }
  let(:schedule) { create(:facility_schedule, facility: facility, week_day: :monday) }

  # Stub Devise authentication methods
  before do
    allow(controller).to receive_messages(authenticate_user!: true, current_user: admin_user, user_signed_in?: true)
  end

  describe "GET #new" do
    it "assigns time slot with default values" do
      get :new, params: { facility_id: facility.id, schedule_id: schedule.id }
      expect(assigns(:time_slot).from_hour).to eq(9)
      expect(assigns(:time_slot).to_hour).to eq(17)
    end
  end

  describe "POST #create" do
    it "creates a time slot" do
      expect do
        post :create, params: { facility_id: facility.id, schedule_id: schedule.id, facility_time_slot: { start_time: "09:00", end_time: "17:00" } }
      end.to change(FacilityTimeSlot, :count).by(1)
    end

    it "parses time correctly" do
      post :create, params: { facility_id: facility.id, schedule_id: schedule.id, facility_time_slot: { start_time: "09:00", end_time: "17:00" } }
      expect(assigns(:time_slot).from_hour).to eq(9)
      expect(assigns(:time_slot).from_min).to eq(0)
    end
  end

  describe "DELETE #destroy" do
    let(:time_slot) { create(:facility_time_slot, facility_schedule: schedule, from_hour: 9, to_hour: 17, from_min: 30, to_min: 0) }

    it "destroys time slot" do
      # The record is destroyed, so trying to reload it raises RecordNotFound
      delete :destroy, params: { facility_id: facility.id, schedule_id: schedule.id, id: time_slot.id }
      expect { time_slot.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "redirects" do
      delete :destroy, params: { facility_id: facility.id, schedule_id: schedule.id, id: time_slot.id }
      expect(response).to redirect_to(admin_facility_path(id: facility.id))
    end

    it "sets flash notice" do
      delete :destroy, params: { facility_id: facility.id, schedule_id: schedule.id, id: time_slot.id }
      expect(flash[:notice]).to match(/Successfully deleted time slot/)
    end
  end
end

RSpec.describe Admin::FacilityLocationsController do
  let(:admin_user) { create(:user, :admin, :verified) }
  let(:facility) { create(:facility) }

  # Stub Devise authentication methods
  before do
    allow(controller).to receive_messages(authenticate_user!: true, current_user: admin_user, user_signed_in?: true)
  end

  describe "GET #index" do
    it "assigns facility" do
      get :index, params: { facility_id: facility.id }
      expect(assigns(:facility)).to eq(facility)
    end
  end

  describe "GET #new" do
    it "assigns location from facility" do
      get :new, params: { facility_id: facility.id }
      expect(assigns(:location).address).to eq(facility.address)
    end
  end

  describe "POST #create" do
    it "updates facility" do
      post :create, params: { facility_id: facility.id, location: { address: "123 New Address", lat: "49.2827", long: "-123.1207" } }
      expect(facility.reload.address).to eq("123 New Address")
    end

    it "redirects" do
      post :create, params: { facility_id: facility.id, location: { address: "123 New Address", lat: "49.2827", long: "-123.1207" } }
      expect(response).to redirect_to(admin_facility_path(facility))
    end
  end

  describe "Turbo Stream response" do
    it "renders turbo stream on success" do
      request.env["HTTP_ACCEPT"] = "text/vnd.turbo-stream.html"
      post :create, params: {
        facility_id: facility.id,
        location: { address: "New Address", lat: "49.2827", long: "-123.1207" }
      }
      expect(response.media_type).to include("turbo-stream")
    end
  end

  describe "search integration" do
    it "calls Locations::Searcher with query" do
      mock_locations = [instance_double(Location)]
      allow(Locations::Searcher).to receive(:call).with(address: "downtown").and_return(mock_locations)
      get :new, params: { facility_id: facility.id, q: "downtown" }
      expect(assigns(:locations)).to eq(mock_locations)
    end
  end
end
# rubocop:enable RSpec/MultipleDescribes
