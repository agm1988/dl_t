class UpdateIndexesOnEvents < ActiveRecord::Migration[5.2]
  def up
    remove_index :events, [:kind, :starts_at, :ends_at]
    remove_index :events, [:kind, :weekly_recurring, :starts_at]

    add_index :events,
              [:starts_at, :ends_at],
              where: "kind = 'appointment'",
              name: 'index_events_appointments_on_starts_at_and_ends_at'

    add_index :events,
              :starts_at,
              where: "kind = 'opening' AND weekly_recurring = 'f'",
              name: 'index_events_not_recurring_openings_on_starts_at'

    add_index :events,
              'EXTRACT(DOW FROM starts_at)',
              where: "kind = 'opening' AND weekly_recurring = 't'",
              name: 'index_events_recurring_openings_on_starts_at_dow'
  end

  def down
    remove_index :events, name: 'index_events_appointments_on_starts_at_and_ends_at'
    remove_index :events, name: 'index_events_not_recurring_openings_on_starts_at'
    remove_index :events, name: 'index_events_recurring_openings_on_starts_at_dow'

    add_index :events, [:kind, :starts_at, :ends_at]
    add_index :events, [:kind, :weekly_recurring, :starts_at]
  end
end
