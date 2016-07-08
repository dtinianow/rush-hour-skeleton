class ChangeRequestedAtDataTypeToText < ActiveRecord::Migration
  def change
    remove_column :payload_requests, :requested_at, :datetime
    add_column :payload_requests, :requested_at, :text
  end
end
