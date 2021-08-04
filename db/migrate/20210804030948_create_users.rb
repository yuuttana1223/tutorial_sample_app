class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      # created_atとupdated_atが生成
      t.timestamps
    end
  end
end
