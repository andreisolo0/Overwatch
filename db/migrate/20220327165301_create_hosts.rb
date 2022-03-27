class CreateHosts < ActiveRecord::Migration[6.1]
  def change
    create_table :hosts do |t|
      t.string :hostname
      t.string :ip_address_or_fqdn
      
      t.timestamps
    end
  end
end
