class PageTemplateSection < ActiveRecord::Base
  belongs_to :page_template
  belongs_to :section
end
