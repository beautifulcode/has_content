class AssetsController < AppController
  
  inherit_resources
  
  before_filter :determine_asset_class
  
  # defaults :resource_class => User, :collection_name => @asset_class.tableize, :instance_name => @asset_class.underscore
  
  
  
  def index
    # redirect_to_admin unless @asset_class
    per_page = params[:per_page] if params[:per_page]
    per_page ||= 20
    # sort_conditions = {params[:sort_by].to_s}
    sort_conditions ||= {}
    @assets = @asset_class.find(:all, :conditions => sort_conditions).paginate :per_page => per_page, :page => params[:page]
    respond_to do |wants|
      wants.html { render_asset_template }
      wants.xml { render :template => "#{@asset_class.tableize}/index" }
    end
  end
  
  
  def determine_asset_class
    @asset_class = params[:controller].classify.constantize unless params[:controller] == 'assets'
    @asset_class ||= params[:asset_type].classify.constantize if params[:asset_type]
    redirect_to_admin unless @asset_class
  end

  def render_asset_template
    if File.exists? "#{RAILS_ROOT}/#{@asset_class.to_s.tableize}/index"
      render :template => "#{@asset_class.to_s.tableize}/index"
    else
      render :template => 'assets/index'
    end
  end

  def redirect_to_admin
    flash[:error] = "Unknown asset type"
    redirect_to admin_path and return
  end
  
  
  protected

    def begin_of_association_chain
      determine_asset_class
    end  
  

end
