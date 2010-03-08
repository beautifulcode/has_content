class Page < ActiveRecord::Base
  
  # Rails Associations
  has_many :content_mappings
  belongs_to :page_template
  has_many :sections, :through => :page_template, :source => :sections
  
  
  # Plugin Declarations
  acts_as_tree
  acts_as_nested_set :dependent => :destroy
  has_friendly_id :title, :use_slug => true, :cache_column => 'file_name', :scope => :parent, :strip_diacritics => true
  
  # Validations
  validates_presence_of :title
  
  
  # Named Scopes
  named_scope :active, :conditions => {:active => true}
  named_scope :visible, :conditions => {:visible => true, :active => true}
  
  
  before_save :update_permalink
  
  def layout
    page_template ? page_template.file : 'site'
  end
  
  def sections
    if page_template && !page_template.sections.empty?
      page_template.sections
    else
      Section.all
    end
  end
  
  def assets
    content.collect(&:asset)
  end
  
  alias content content_mappings
  
  def permalink_path
    @ancestor_path = self_and_ancestors.collect{|a| a.slug.name }.uniq
    @ancestor_path.shift
    path = "/#{@ancestor_path.join('/')}"
    path
  end
  
  def content=(asset_array, section = 'Main')
    asset_array = [asset_array] unless asset_array.is_a? Array
    asset_array.each{|asset| add_content( asset, section ) }
  end
  
  define_method 'content<<' do
    add_content(asset)
  end
  
  def add_content(asset, section_title = 'Main')
    section = Section.find_by_title(section_title)
    asset_type = AssetType.find_or_create_by_title(asset.class.name)
    position = self.content_mappings.size
    content = ContentMapping.create(:asset_id => asset.id, :asset_type_id => asset_type.id, :section_id => section.id)
    self.content_mappings << content
    content
  end
  
  
  def content_for_section(section)
    section = Section.find_by_title(section) if section.is_a? String
    mappings = ContentMapping.find_all_by_page_id_and_section_id(self, section)
  end
  
  def assets_for_section(title)
    content_for_section(title).collect(&:asset)
  end
  
  def update_permalink
    ancestors_without_root = self_and_ancestors - [Page.root]
    self.permalink = ancestors_without_root.collect{|a| a.slug.name }.join('/')
  end
  
  def page_select_value
    if ancestors
      arr = ancestors.map{ |a| "-" } << title
      arr.join
    else
      title
    end
  end
  
  def nav_title
    determine_title
  end
  
  def meta_title
    determine_title
  end
  
  def determine_title
    if !title_override.blank?
      title_override
    else
      title
    end
  end
    
  def title_override
    title
  end
  
end
