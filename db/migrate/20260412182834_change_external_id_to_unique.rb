class ChangeExternalIdToUnique < ActiveRecord::Migration[8.1]
  def up
    # Handle duplicates by making them unique first (append "-dup-{id}")
    # This preserves all data including facility_services associations
    duplicate_ids = Facility.external
      .group(:external_id)
      .having("COUNT(*) > 1")
      .pluck(:external_id)

    # By updating older records first, we ensure that the most recently
    #   updated record retains the original external_id, which is likely
    #   the most accurate
    external_facilities = Facility.external
      .where(external_id: duplicate_ids)
      .order(updated_at: :asc)
      .to_a
    external_facilities.each do |facility|
      # Check if there are still duplicates after we've modified some
      still_duplicates = Facility.external
        .where(external_id: facility.external_id)
        .count
      next unless still_duplicates > 1

      # Update this record's external_id to be unique
      new_external_id = "#{facility.external_id}-dup-#{facility.id}"
      facility.update!(external_id: new_external_id)
    end

    add_index :facilities, :external_id, unique: true, where: "external_id IS NOT NULL"
  end

  def down
    remove_index :facilities, :external_id
  end
end
