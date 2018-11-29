class AddIndexesToEvents < ActiveRecord::Migration[5.2]
  def change
    add_index :events, [:kind, :starts_at, :ends_at]
    add_index :events, [:kind, :weekly_recurring, :starts_at]
  end
end
