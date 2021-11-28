# frozen_string_literal: true

class Admin::AlertsController < Admin::BaseController
  before_action :load_alerts, only: %i[index]
  before_action :load_alert, only: %i[show edit update destroy]

  def index; end

  def new
    @alert = Alert.new(active: false) #(admin: false, verified: false)
  end

  def show; end

  def edit; end

  def create
    @alert = Alert.new(alert_params)
    if @alert.save
      redirect_to [:admin, @alert], notice: "Successfully created alert (id: #{@alert.id}, title: #{@alert.title})"
    else
      flash.now[:alert] = "Failed to create alert. Errors: #{@alert.errors.full_messages.join('; ')}"

      render action: :new, status: :unprocessable_entity
    end
  end

  def update
    if @alert.update(alert_params)
      redirect_to [:admin, @alert], notice: "Successfully updated alert (id: #{@alert.id})"
    else
      flash.now[:alert] = "Failed to update alert (id: #{@alert.id}). Errors: #{@alert.errors.full_messages.join('; ')}"

      render action: :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @alert.destroy
      flash[:notice] = "Successfully deleted Alert #{@alert.title} (id: #{@alert.id})"

      redirect_to action: :index
    else
      # Error when turning Welcome on.
      flash[:error] = "Failed to delete Alert #{@alert.title} (id: #{@alert.id}). Errors: #{@alert.errors.full_messages.join('; ')}"

      render action: :show, status: :unprocessable_entity
    end
  end

  private

  def load_alerts
    alerts = Alert.all

    @pagy, @alerts = pagy(alerts)
  end

  def load_alert
    @alert = Alert.find(params[:id])
  end

  def alert_params
    params.require(:alert).permit(:title, :content, :active)
  end
end
