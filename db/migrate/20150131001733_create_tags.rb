class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string  :name, :limit => 1024
      t.timestamps
    end

    create_table :charities_tags do |t|
      t.references :charity, :null => false, index: true
      t.references :tag, :null => false, index: true
    end

    create_table :campaigns_tags do |t|
      t.references :campaign, :null => false, index: true
      t.references :tag, :null => false, index: true
    end

    add_index(:charities_tags, [:charity_id, :tag_id], :unique => true)    
    add_index(:campaigns_tags, [:campaign_id, :tag_id], :unique => true)
    add_index :tags, :id
  end
end