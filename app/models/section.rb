class Section < ActiveRecord::Base
  has_many :content_mappings
  # has_many :assets, :through => :content_mappings, :source => :asset
  
  def assets
    content_mappings.collect{|mapping| mapping.asset }
  end
  
  def available_assets
    assets.collect{|asset| asset.class }.uniq
  end
  
end
