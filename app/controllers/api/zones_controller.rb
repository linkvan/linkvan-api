class Api::ZonesController < Api::BaseController
  skip_before_action :require_signin, only: [:index]
  before_action :require_admin, except: [:index]

  # GET api/zones
  def index
    @zones = Zone.all

    @response = ZonesSerializer.new(@zones)
    render json: @response, status: :ok
  end #/index

  # GET api/zones/:id/admin
  def list_admin
    @zone = Zone.find params[:id]
    @zone_admins = @zone.users
    @responde = { users: @zone_admins }
    render json: @responde, status: :ok
  end #/list_admin

  # POST api/zones/:id/admin
  def add_admin
    @zone = Zone.find(params[:id])
    @user = User.find(params[:user_id])

    if (@user.zones << @zone)
      render json: ZoneSerializer.new(@zone), status: :created
    else
      head :conflict
    end
  end #/add_admin

  # DELETE api/zones/:id/admin
  def remove_admin
    @zone = Zone.find(params[:id])
    @user = User.find(params[:user_id])

    if @user.zones.delete @zone
      render json: ZoneSerializer.new(@zone), status: :ok
    else
      head :conflict
    end
  end #/remove_admin
  
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
  end #/facility_params
end #/ZonesController
