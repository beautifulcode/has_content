class CreateHasContent < ActiveRecord::Migration
  def self.up
    # unless check_table('pages')
      create_table :pages do |t|
        t.string :title
        t.string :file_name
        t.integer :position
        t.integer :parent_id
        t.integer :lft
        t.integer :rgt
        t.string :permalink
        t.integer :page_template_id
        t.boolean :visible, :null => false, :default => true
        t.boolean :active, :null => false, :default => true
        t.text :meta_keywords
        t.text :meta_description
        t.boolean :redirect, :null => false, :default => false
        t.integer :redirect_page_id
        t.string :redirect_url
        t.string :css_class
        t.string :nav_item_css_class
        t.string :nav_item_param
        t.boolean :lightwindow, :null => false, :default => false

        t.timestamps
      end
    # end
    
    unless check_table('slugs')
      create_table :slugs do |t|
        t.string :name
        t.integer :sluggable_id
        t.integer :sequence, :null => false, :default => 1
        t.string :sluggable_type, :limit => 40
        t.string :scope, :limit => 40
        t.datetime :created_at
      end
    end
    
    create_table :sections do |t|
      t.string :title

      t.timestamps
    end
    
    Section.create(:title => "Main")
    Section.create(:title => "Side")
    
    create_table :content_mappings do |t|
      t.integer :page_id
      t.integer :section_id
      t.integer :asset_id
      t.integer :asset_type_id, :default => 0
      t.string :asset_template
      t.integer :position
    
      t.timestamps
    end
    
    create_table :page_templates do |t|
      t.string :title
      t.string :file
      t.boolean :active

      t.timestamps
    end
    
    PageTemplate.create(:title => "Home", :file => 'home')
    PageTemplate.create(:title => "Default", :file => 'site')
    
    create_table :page_template_sections do |t|
      t.integer :page_template_id
      t.integer :section_id

      t.timestamps
    end
    
    create_table :asset_types do |t|
      t.string :title
      t.boolean :active

      t.timestamps
    end
    
    create_table :text_blocks do |t|
      t.string :title
      t.text :content
      t.text :filter
    
      t.timestamps
    end
    
    AssetType.create(:name => "TextBlock")
    
    create_table :images do |t|
      t.string :title
      t.string :file_file_name
      t.string :file_content_type
      t.integer :file_file_size
      t.integer :page_id
      t.string :link
      t.text :caption
      t.string :alignment
      t.string :css_class

      t.timestamps
    end
    
    AssetType.create(:name => "Image")
    
    create_table :flash_pieces do |t|
      t.string :title
      t.string :width
      t.string :height
      t.string :params
      t.string :flash_vars
      t.string :version

      t.timestamps
    end
  end
  
  

  def self.down
    drop_table :images
    drop_table :text_blocks
    drop_table :asset_types
    drop_table :content_mappings
    drop_table :sections
    drop_table :slugs
    drop_table :pages

  end
  
  
  
  
  
  def self.check_table(name)
      begin
        Piece.connection.execute("select 1 from #{name}")
        say "Checking For Table: #{name} => Table Found"
        return false;
      rescue
        say "Checking For Table: #{name} => Table Not Found"
        return true;
      end
    end
  
  
  
end


