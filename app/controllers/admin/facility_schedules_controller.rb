# frozen_string_literal: true

class Admin::FacilitySchedulesController < Admin::BaseController
  before_action :load_facility
  before_action :load_schedule, only: %i[edit update]

  def new; end

  def edit; end

  def create
    @schedule = @facility.schedules.build(create_schedule_params)

    if @schedule.save
      flash[:notice] =
        "Successfully created #{@schedule.week_day} schedule for #{facility_description}"
    else
      flash[:alert] =
        "Failed to create #{@schedule.week_day} schedule for #{facility_description}"
    end

    redirect_to admin_facility_path(id: params[:facility_id])
  end

  def update
    @schedule.assign_attributes(update_schedule_params)

    FacilitySchedule.transaction do
      if @schedule.open_all_day? || @schedule.closed_all_day?
        # Instantiate and Destroy all associated FacilityTimeSlots
        @schedule.time_slots.destroy_all
      end

      if @schedule.save
        flash[:notice] =
          "Successfully updated #{@schedule.week_day} schedule for #{facility_description} to #{@schedule.availability}"
      else
        failed_message =
          "Failed to update #{@schedule.week_day} schedule for #{facility_description} to #{@schedule.availability}"
        flash[:alert] = "#{failed_message}. Errors: #{@schedule.errors.full_messages}"
        raise ActiveRecord::Rollback, "Failed to update"
      end
    end

    redirect_to admin_facility_path(id: params[:facility_id])
  end

  private

  def facility_description
    "Facility #{@facility.name} (id: #{@facility.id})"
  end

  def load_facility
    @facility = Facility.find(params[:facility_id])
  end

  def load_schedule
    @schedule = @facility.schedules.find(params[:id])
  end

  def create_schedule_params
    params.require(:schedule).permit(:week_day).merge(update_schedule_params)
  end

  def update_schedule_params
    params.require(:schedule).permit(:open_all_day, :closed_all_day)
  end
end
