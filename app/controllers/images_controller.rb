class ImagesController < AssetsController
  def index
    @images = Image.paginate(:all, :page => params[:page])
  end
end
