# frozen_string_literal: true

class Api::ZonesController < Api::BaseController
  # skip_before_action :authenticate_user!, only: [:index]
  before_action :require_admin, except: [:index]

  # GET api/zones
  def index
    @zones = Zone.includes(:facilities, :users)

    @response = ZonesSerializer.call(@zones)
    render json: @response, status: :ok
  end

  # GET api/zones/:id/admin
  def list_admin
    @zone = Zone.find params[:id]
    @zone_admins = @zone.users
    @response = { users: @zone_admins }
    render json: @response, status: :ok
  end

  # POST api/zones/:id/admin
  def add_admin
    @zone = Zone.find(params[:id])
    @user = User.find(params[:user_id])

    if @user.zones.exists?(@zone.id) || !(@user.zones << @zone)
      head :conflict
    else
      render json: ZoneSerializer.call(@zone), status: :created
    end
  end

  # DELETE api/zones/:id/admin
  def remove_admin
    @zone = Zone.find(params[:id])
    @user = User.find(params[:user_id])

    if @user.zones.exists?(@zone.id) && @user.zones.delete(@zone)
      render json: ZoneSerializer.call(@zone), status: :ok
    else
      head :conflict
    end
  end

  # def filteredtest
  #     @fs = { :nearyes => Facility.where("id<=3"), :nearno => Facility.where("id>8")}.to_json

  #     render :json => @fs
  # end

  # def show
  #   @facility = Facility.find(params[:id])
  #   render :json => @facility.to_json
  # end

  private

  def zone_params
    params.permit(
      :name, :description
    )
  end
end
