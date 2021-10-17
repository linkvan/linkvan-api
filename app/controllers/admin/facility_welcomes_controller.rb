# frozen_string_literal: true

class Admin::FacilityWelcomesController < Admin::BaseController
  before_action :load_facility
  before_action :load_facility_welcome

  def create
    customer = new_welcome_params[:customer] || @facility_welcome&.customer

    if @facility_welcome.present?
      # Welcome already turned on
      flash[:notice] = "Facility #{@facility.name} (id: #{@facility.id}) already had welcome '#{customer}' turned on"
    else
      @facility_welcome = @facility.facility_welcomes.new(new_welcome_params)

      if @facility_welcome.save
        # Welcome turned on
        flash[:notice] = "Successfully turned on welcome '#{customer}' for Facility #{@facility.name} (id: #{@facility.id}"
      else
        # Welcome failed to be turned on.
        flash[:error] = "Failed to turn on welcome '#{customer}' for Facility #{@facility.name} (id: #{@facility.id}. Errors: #{@facility_welcome.errors.full_messages.join('; ')}"
      end
    end

    redirect_to admin_facility_path(id: params[:facility_id])
  end

  def destroy
    customer = @facility_welcome&.customer || params[:customer]

    if @facility_welcome.blank?
      # Welcome wasn't turned on
      flash[:notice] = "Facility #{@facility.name} (id: #{@facility.id}) already had welcome '#{customer}' turned off"
    elsif @facility_welcome.destroy
      # Welcome was turned on
      flash[:notice] = "Successfully turned off welcome '#{customer}' for Facility #{@facility.name} (id: #{@facility.id}"
    else
      # Error when turning Welcome on.
      flash[:error] = "Failed to turn off welcome '#{customer}' for Facility #{@facility.name} (id: #{@facility.id}"
    end

    redirect_to admin_facility_path(id: params[:facility_id])
  end

  private

  def load_facility_welcome
    relevant_welcomes = @facility.facility_welcomes
    @facility_welcome = relevant_welcomes.find_by(id: params[:id]) ||
                        relevant_welcomes.find_by(customer: params[:customer])
  end

  def load_facility
    @facility = Facility.find(params[:facility_id])
  end

  def new_welcome_params
    params.permit(:customer)
  end
end
