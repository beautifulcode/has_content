class AssetType < ActiveRecord::Base
  validates_presence_of :title
  has_many :content_mappings
  def icon
    case title
    when 'TextBlock'
      "#{@plugin_asset_path}/images/icons/text_align_left.png"
    when 'BasicImage'
      "#{@plugin_asset_path}/images/icons/image.png"
    else
      ''
    end
  end
end
