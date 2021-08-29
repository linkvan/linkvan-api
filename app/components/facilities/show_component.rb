# frozen_string_literal: true

class Facilities::ShowComponent < ViewComponent::Base
  attr_reader :facility

  def initialize(facility:)
    @facility = facility
  end

  delegate :user, to: :facility

  def card_id
    dom_id(facility)
  end

  def link_to_website
    link_to facility.website, URI::HTTP.build({ host: facility.website }).to_s
  end

  def status_icon
    tag.span class: status_icon_span_class do
      tag.i title: status_title, class: status_icon_class
    end
  end

  def status_title
    facility.status.to_s.titleize
  end

  def status_icon_class
    case facility.status
    when :live
      "fas fa-check-square"
    when :pending_reviews
      "fas fa-times"
    else
      "fas"
    end
  end

  def status_icon_span_class
    case facility.status
    when :live
      "icon has-text-success"
    when :pending_reviews
      "icon has-text-danger"
    else
      "icon"
    end
  end

  class LocationCardComponent < ViewComponent::Base
    attr_reader :facility

    def initialize(facility:)
      @facility = facility
    end
  end

  class ServicesCardComponent < ViewComponent::Base
    attr_reader :facility

    def initialize(facility:)
      @facility = facility
    end

    private

    def switch_button(service)
      options = {
        class: "button is-white is-pulled-right"
      }

      if provides_service?(service)
        target_url = admin_facility_service_path(facility_id: facility.id, service_id: service.id)
        options[:method] = :delete
        options[:data] = { confirm: "Are you sure you want to turn off '#{service.name}' service for this facility?\nNotes associated with this service will also be deleted." }
      else
        target_url = admin_facility_services_path(facility_id: facility.id, service_id: service.id)
        options[:method] = :post
      end

      link_to(target_url, options)  do
        render Shared::StatusComponent.new(provides_service?(service))
      end
    end

    def show_notes_button(service)
      if facility_service_for(service).present?
        button_data = { modal_id: note_modal_id(service) }
        tag.button class: "button is-white show_notes_button is-pulled-right", data: button_data do
          tag.span class: "icon" do
            tag.i class: "fas fa-edit"
          end
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

  class WelcomesCardComponent < ViewComponent::Base
    attr_reader :facility

    def initialize(facility:)
      @facility = facility
    end

    private

    def welcomes?(welcome)
      facility.welcomes_list[welcome].present?
    end

    def all_welcomes
      Facility::WELCOMES
    end
  end

  class ScheduleCardComponent < ViewComponent::Base
    attr_reader :facility

    def initialize(facility:)
      @facility = facility
    end

    private

    def schedules
      facility.schedules
    end

    def link_to_edit(schedule)
      link_to "Edit", "#", class: "button"
    end
  end
end
