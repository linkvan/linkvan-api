# frozen_string_literal: true

require_relative "base_page"

class AdminNoticeNewPage < BasePage
  def visit_new_notice
    visit_page new_admin_notice_path
    self
  end

  def create_notice(attributes = {})
    fill_in "Title", with: attributes[:title] || "Test Notice"
    fill_trix_editor "Content", with: attributes[:content] || "Test content"
    # Handle published checkbox - default to unpublished unless specified
    if attributes[:published]
      check "Published"
    else
      uncheck "Published"
    end
    click_button "Create Notice"
  end

  public

  def fill_trix_editor(label, with:)
    # Find trix editor using multiple approaches for ActionText compatibility
    trix_editor = find_trix_editor(label)
    
    # Use JavaScript to set the Trix editor content
    execute_script("arguments[0].editor.insertHTML(arguments[1])", trix_editor, with)
  end

  def find_trix_editor(label)
    # Approach 1: Try to find trix-editor directly (most reliable)
    begin
      return find("trix-editor")
    rescue Capybara::ElementNotFound
      # Continue to next approach
    end

    # Approach 2: Try to original method with error handling
    begin
      field = find_field(label)
      field_id = field[:id]
      return find("##{field_id}_trix_editor")
    rescue Capybara::ElementNotFound
      # Continue to next approach
    end

    # Approach 3: Find by hidden input name pattern (ActionText specific)
    begin
      # Look for hidden input with name containing 'content'
      hidden_input = find("input[name*='[content]']")
      field_id = hidden_input[:id]
      
      # Try different ID patterns for trix editor
      possible_ids = [
        "#{field_id}_trix_editor",
        field_id.gsub('_input', '') + "_trix_editor",
        field_id.gsub('_input', '')
      ]
      
      possible_ids.each do |trix_id|
        begin
          return find("##{trix_id}")
        rescue Capybara::ElementNotFound
          next
        end
      end
    rescue Capybara::ElementNotFound
      # Continue to fallback
    end

    # Approach 4: Fallback to any trix-editor
    begin
      return all("trix-editor").first
    rescue
      raise "Could not find trix editor for label '#{label}'"
    end
  end

  def has_form_errors?
    has_content?("can't be blank") || has_css?(".field_with_errors")
  end
end
