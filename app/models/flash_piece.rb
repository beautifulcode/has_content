class FlashPiece < Asset
  has_attached_file :swf
  has_attached_file :french_swf
  has_attached_file :image
  
  def flash_version
    fv = version unless version.blank?
    fv ||= '9'
  end
end