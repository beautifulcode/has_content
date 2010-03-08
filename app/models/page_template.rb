class PageTemplate < ActiveRecord::Base
  has_many :pages
  has_many :page_template_sections
  has_many :sections, :through => :page_template_sections
end
