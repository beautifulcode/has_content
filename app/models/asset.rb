class Asset < ActiveRecord::Base
  self.abstract_class = true
  has_many :content_mappings, :dependent => :destroy
  has_many :pages, :through => :content_mappings
  has_many :sections, :through => :content_mappings
  
  validates_presence_of :title

  def partial
    self.class.name.tableize.singularize
  end

end
