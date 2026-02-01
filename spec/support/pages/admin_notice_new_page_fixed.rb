# frozen_string_literal: true

require_relative "base_page"

class AdminNoticeNewPageFixed < BasePage
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

  private

  def fill_trix_editor(label, with:)
    # Multiple approaches to find the trix editor
    trix_editor = find_trix_editor_for_label(label)

    # Use JavaScript to set the Trix editor content
    execute_script("arguments[0].editor.insertHTML(arguments[1])", trix_editor, with)
  end

  def find_trix_editor_for_label(label)
    # Approach 1: Try to find trix-editor directly (simplest)
    begin
      return find("trix-editor")
    rescue Capybara::ElementNotFound
      puts "Approach 1 failed: Could not find trix-editor directly"
    end

    # Approach 2: Try the original method
    begin
      field_id = find_field(label)[:id]
      return find("##{field_id}_trix_editor")
    rescue Capybara::ElementNotFound
      puts "Approach 2 failed: Could not find field with label '#{label}'"
    end

    # Approach 3: Find by hidden input pattern (most reliable for ActionText)
    begin
      # Look for hidden input with name containing 'content'
      hidden_inputs = all("input[name*='[content]']")
      hidden_inputs.each do |input|
        field_id = input[:id]
        # Try multiple ID patterns
        trix_id_patterns = [
          "#{field_id}_trix_editor",
          field_id.gsub("_input", "") + "_trix_editor",
          field_id.gsub("_input", "")
        ]

        trix_id_patterns.each do |trix_id|
          return find("##{trix_id}")
        rescue Capybara::ElementNotFound
          next
        end
      end
    rescue StandardError => e
      puts "Approach 3 failed: #{e.message}"
    end

    # Approach 4: Find by data attributes or other patterns
    begin
      # Look for any trix-editor elements and use the first one
      trix_editors = all("trix-editor")
      return trix_editors.first if trix_editors.any?
    rescue StandardError => e
      puts "Approach 4 failed: #{e.message}"
    end

    raise "Could not find trix editor for label '#{label}' after trying all approaches"
  end

  def has_form_errors?
    has_content?("can't be blank") || has_css?(".field_with_errors")
  end
end
