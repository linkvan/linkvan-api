# frozen_string_literal: true

class Facilities::ShowComponent < ViewComponent::Base
  attr_reader :facility

  def initialize(facility:)
    super()

    @facility = facility
  end

  def card_id
    dom_id(facility)
  end

  class ShowComponentBase < ViewComponent::Base
    attr_reader :facility

    def initialize(facility:)
      super()

      @facility = facility
    end
  end

  class DetailsCardComponent < ShowComponentBase
    delegate :user, to: :facility

    private

    def link_to_website
      link_to facility.website_url, facility.website_url, target: "_blank", rel: "noopener"
    end

    def status_component
      @status_component ||= Facilities::StatusComponent.new(facility.status)
    end
  end

  class LocationCardComponent < ShowComponentBase
  end

  class ServicesCardComponent < ShowComponentBase
    private

    def switch_button(service)
      options = {
        class: "button is-white is-pulled-right",
        data: {}
      }

      if provides_service?(service)
        target_url = admin_facility_service_path(facility_id: facility.id, service_id: service.id)
        options[:data][:turbo_method] = :delete

        if notes_for(service).present?
          options[:data][:confirm] = [
            "Are you sure you want to turn off '#{service.name}' service for this facility?",
            "Notes associated with this service will also be deleted."
          ].join("\n")
        end
      else
        target_url = admin_facility_services_path(facility_id: facility.id, service_id: service.id)
        options[:data][:turbo_method] = :post
      end

      link_to(target_url, **options) do
        render Shared::StatusComponent.new(provides_service?(service))
      end
    end

    def show_notes_button(service)
      return if facility_service_for(service).blank?

      button_data = { modal_id: note_modal_id(service) }
      tag.with_button class: "button is-white show_notes_button is-pulled-right", data: button_data do
        tag.span class: "icon" do
          tag.i class: "fas fa-edit"
        end
      end
    end

    def note_modal_id(service)
      "note_modal_#{service.id}"
    end

    def notes_for(service)
      facility_service_for(service)&.note
    end

    def provides_service?(service)
      facility_service_for(service).present?
    end

    def facility_service_for(service)
      facility.facility_services.find_by(service: service)
    end

    def all_services
      Service.all
    end
  end

  class WelcomesCardComponent < ShowComponentBase
    private

    def switch_button(customer)
      options = {
        class: "button is-white is-pulled-right"
      }

      customer_value = customer_value_for(customer)

      if welcomes?(customer_value)
        target_url = admin_facility_welcome_path(id: facility_welcome_for(customer),
                                                 customer: customer_value,
                                                 facility_id: facility.id)
        options[:data] = { confirm: "Are you sure you want to turn off welcome '#{customer_value}' for this facility?",
                           turbo_method: :delete }
      else
        target_url = admin_facility_welcomes_path(facility_id: facility.id,
                                                  customer: customer_value)
        options[:data] = { turbo_method: :post }
      end

      link_to(target_url, **options) do
        render Shared::StatusComponent.new(welcomes?(customer_value))
      end
    end

    def welcomes?(customer)
      facility.facility_welcomes.exists?(customer: customer_value_for(customer))
    end

    def customer_value_for(customer)
      customer.respond_to?(:value) ? customer.value : customer
    end

    def facility_welcome_for(customer)
      facility.facility_welcomes.find_by(customer: customer_value_for(customer))
    end

    def all_customers
      FacilityWelcome.all_customers
    end
  end

  class ScheduleCardComponent < ShowComponentBase
    private

    def switch_button(schedule)
      options = {
        class: "button is-white is-pulled-right",
        data: {}
      }

      schedule_params = {
        week_day: schedule.week_day,
        closed_all_day: false,
        open_all_day: true
      }

      if schedule.new_record?
        # Create a new Schedule
        target_url = admin_facility_schedules_path(facility_id: facility.id,
                                                   schedule: schedule_params)

        options[:data][:turbo_method] = :post
      else
        if schedule.closed_all_day?
          # Schedule is closed_all_day. Update it to open_all_day
          schedule_params[:closed_all_day] = false
          schedule_params[:open_all_day] = true
        else
          # Schedule is open_all_day or set_times. Update it to closed_all_day
          schedule_params[:closed_all_day] = true
          schedule_params[:open_all_day] = false

          if schedule.time_slots.exists?
            options[:data][:confirm] = [
              "Are you sure you want to switch the #{schedule.week_day} schedule to closed all day?",
              "Time Slots associated with this schedule will also be deleted."
            ].join("\n")
          end

        end

        target_url = admin_facility_schedule_path(facility_id: facility.id,
                                                  id: schedule.id,
                                                  schedule: schedule_params)
        options[:data][:turbo_method] = :put
      end

      link_to(target_url, **options) do
        render Shared::StatusComponent.new(schedule.availability != :closed)
      end
    end

    def full_schedule
      return to_enum(:full_schedule) unless block_given?

      week_days.each do |week_day|
        # data = { week_day: week_day, schedule: schedule_for(week_day) }
        data = schedule_for(week_day)
        yield data
      end
    end

    def week_days
      FacilitySchedule.week_days.values
    end

    def schedule_for(week_day)
      schedules.find_by(week_day: week_day) ||
        FacilitySchedule.new(facility: facility, week_day: week_day)
    end

    def schedule_exists?
      schedules.find_by(week_day: week_day).present?
    end

    def schedules
      facility.schedules
    end

    def link_to_add_time_slot(schedule)
      action = new_admin_facility_time_slot_path(facility_id: facility.id, schedule_id: schedule.id)

      link_to action, class: "button is-pulled-right is-white" do
        icon_element("fa-plus-square")
      end
    end

    def link_to_edit(schedule)
      action = if schedule.new_record?
        new_admin_facility_schedule_path(facility_id: facility.id)
      else
        edit_admin_facility_schedule_path(id: schedule.id, facility_id: facility.id)
      end

      link_to action, class: "button is-pulled-right is-white" do
        icon_element("fa-edit")
      end
    end

    def link_to_destroy(time_slot)
      schedule_id = time_slot.facility_schedule.id

      action = admin_facility_time_slot_path(facility_id: facility.id,
                                             schedule_id: schedule_id,
                                             id: time_slot.id)

      link_to action, class: "button is-pulled-right is-white", data: { turbo_method: :delete } do
        icon_element("fa-trash")
      end
    end

    def icon_for(_schedule)
      icon_class = "fa-plus-square"

      icon_element(icon_class)
    end

    def icon_element(icon_classes)
      tag.span(class: "icon") do
        tag.i(class: "fas #{icon_classes}")
      end
    end
  end
end
