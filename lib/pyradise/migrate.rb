require 'sequel/extensions/migration'

class CreatePyradise < Sequel::Migration
  def up
    create_table :products do
      primary_key :id
      varchar :sid
      varchar :name
      varchar :store
      integer :price
      text    :prices
    end
  end


  def down() drop_table :products end

end
