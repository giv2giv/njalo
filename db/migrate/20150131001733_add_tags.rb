class AddTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string  :name, :limit => 1024
      t.timestamps
    end

    create_table :charities_tags do |t|
      t.references :charity, :null => false
      t.references :tag, :null => false
    end

#    add_index(:tags, :name, type: :fulltext) #use elasticsearch instead
    add_index(:charities_tags, [:charity_id, :tag_id], :unique => true)
    add_index :tags, :id
  end
end