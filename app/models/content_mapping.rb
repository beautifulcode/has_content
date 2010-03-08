class ContentMapping < ActiveRecord::Base
  belongs_to :page
  belongs_to :section
  belongs_to :asset_type
  # belongs_to :asset, :polymorphic => true
  # accepts_nested_attributes_for :asset
  
  validates_presence_of :page, :section, :asset_type

  default_scope :order => 'position'
    
  attr_accessor :asset_attributes
  
  def build_asset
    asset_type.classify.send(:new)
  end
  
  def asset
    return nil if asset_type.blank?
    asset_class = class_eval(asset_type.title)
    begin
      the_asset = asset_class.find(asset_id)
    rescue
      
    end
    the_asset || asset_class.new
  end
  
  def asset=(asset)
    self.asset_type = AssetType.find_by_title(asset.class.name.to_s)
    self.asset_id = asset.id
    self.save
  end
  
  def partial
    template = asset_template unless asset_template.blank?
    template ||= asset 
    template
  end
  

end
