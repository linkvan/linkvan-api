# frozen_string_literal: true

class Translator < ApplicationService
  WELCOMES_DICTIONARY = {
    male: %w[],
    female: %w[],
    transgender: %w[],
    children: %w[],
    youth: %w[],
    adult: %w[],
    senior: %w[]
  }.freeze

  SERVICES_DICTIONARY = {
    shelter: %w[housing house],
    medical: %w[],
    food: %w[],
    hygiene: %w[clean cleaning shower],
    technology: %w[computer tech],
    legal: %w[law],
    learning: %w[learn education teacing teach teacher],
    phone: %w[],
    overdose: %w[prevention]
  }

  class << self
    def services_dictionary
      return @services_dictionary unless @services_dictionary.nil?

      @services_dictionary = {}
      # Goes through all current services
      Service.all.each do |service|
        assign(@services_dictionary, key: service.key, value: service.name)
      end

      # Goes through the service specific dictionary
      SERVICES_DICTIONARY.each_pair do |key, values|
        assign(@services_dictionary, key: key, value: key)
        values.each do |value|
          assign(@services_dictionary, key: key, value: value)
        end
      end

      @services_dictionary
    end

    def dictionary
      @dictionary ||= services_dictionary.merge(welcomes_dictionary)
    end

    def welcomes_dictionary
      return @welcomes_dictionary unless @welcomes_dictionary.nil?

      @welcomes_dictionary = {}
      # Goes through all current customer types
      FacilityWelcome.all_customers do |customer_types|
        assign(@welcomes_dictionary, key: customer_types.value, value: customer_types.value)
        assign(@welcomes_dictionary, key: customer_types.value, value: customer_types.name)
      end

      # Goes through the service specific dictionary
      WELCOMES_DICTIONARY.each_pair do |key, values|
        assign(@welcomes_dictionary, key: key, value: key)

        values.each do |value|
          assign(@welcomes_dictionary, key: key, value: value)
        end
      end

      @welcomes_dictionary
    end

    private

    def assign(dictionary, key:, value:)
      variations_for(value).each do |value|
        dictionary[value] = key
      end
    end

    def variations_for(value)
      value_str = value.to_s.downcase

      return value_str.singularize, value_str.pluralize
    end
  end

  def initialize(search_value)
    super()

    @search_value = search_value
  end

  def call
    valid?

    data = {}
    data[:welcomes] = translated_value
    Result.new(data: translated_value, errors: errors)
  end

  def validate
    add_error("Dictionary doesn't have '#{@search_value}' value") if translated_value.blank?
  end

  private

  def translated_value
    self.class.dictionary[@search_value.to_s.downcase]
  end
end
