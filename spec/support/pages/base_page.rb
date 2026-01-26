# frozen_string_literal: true

class BasePage
  include Capybara::DSL
  include Rails.application.routes.url_helpers
  include RSpec::Matchers

  def visit_page(path)
    visit path
    self
  end

  delegate :has_content?, to: :page

  delegate :has_no_content?, to: :page

  def click_link(text)
    page.click_link(text)
    self
  end

  def click_button(text)
    page.click_button(text)
    self
  end

  def fill_in(field, with:)
    page.fill_in(field, with:)
    self
  end

  def select(value, from:)
    page.select(value, from:)
    self
  end

  def check(field)
    page.check(field)
    self
  end

  def uncheck(field)
    page.uncheck(field)
    self
  end

  delegate :current_path, to: :page

  def has_flash_notice?(message)
    page.has_css?(".flash-notice", text: message)
  end

  def has_flash_alert?(message)
    page.has_css?(".flash-alert", text: message)
  end
end
