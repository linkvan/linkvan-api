# frozen_string_literal: true

class Admin::FacilityTimeSlotsController < Admin::BaseController
  before_action :load_facility
  before_action :load_schedule
  before_action :load_time_slot, only: %i[destroy]

  def new
    @time_slot = @schedule.time_slots.build(from_hour: 9, to_hour: 17)
  end

  def create
    # flash[:error] = "Not Implemented #{__method__}. PARAMS: #{params.inspect}"
    @time_slot = @schedule.time_slots.build(time_slot_params)

    time_slot_description = "time slot (#{@time_slot.start_time_for_displaying} - #{@time_slot.end_time_for_displaying})"
    if @time_slot.save && @schedule.update_schedule_availability
      flash[:notice] =
        "Successfully created #{time_slot_description} for #{facility_description}"
    else
      collected_errors = @time_slot.errors.full_messages + @schedule.errors.full_messages
      flash[:alert] =
        "Failed to create #{time_slot_description} for #{facility_description}. Errors: #{collected_errors}"
    end

    redirect_to admin_facility_path(id: params[:facility_id])
  end

  def destroy
    if @time_slot.destroy
      flash[:notice] =
        "Successfully deleted time slot #{@time_slot.id} for the #{@schedule.week_day} schedule"
    else
      flash[:alert] =
        "Failed to delete time slot #{@time_slot.id} for the #{@schedule.week_day} schedule"
    end

    redirect_to admin_facility_path(id: params[:facility_id])
  end

  private

  def facility_description
    "Facility #{@facility.name} (id: #{@facility.id})"
  end

  def load_time_slot
    relevant_time_slots = @schedule.present? ? @schedule.time_slots : @facility.time_slots

    @time_slot = relevant_time_slots.find(params[:id])
  end

  def load_schedule
    @schedule = @facility.schedules.find(params[:schedule_id])
  end

  def load_facility
    @facility = Facility.find(params[:facility_id])
  end

  def time_slot_params
    parameters = params.require(:facility_time_slot).permit(:start_time, :end_time)
    start_time = parameters[:start_time].to_s.to_time
    end_time = parameters[:end_time].to_s.to_time

    {
      from_hour: start_time.hour,
      from_min: start_time.min,
      to_hour: end_time.hour,
      to_min: end_time.min
    }
  end
end
