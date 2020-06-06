class AddActivationEmailSentToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :activation_email_sent, :boolean, :default => false
  end
end
