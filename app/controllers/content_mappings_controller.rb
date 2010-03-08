class ContentMappingsController < AppController

  def sort
    params[:section_main_content].each_with_index do |content_id, i|
      content = ContentMapping.find(content_id)
      content.update_attribute(:position, i)
      content.save
    end
    respond_to do |format|
      format.js {render :text => 'Sorted', :layout => false}
    end
  end
  
  
  def index
    @page = Page.find(params[:page_id]) if params[:page_id]
    @content_mappings = @page.content_mappings if @page
    @content_mappings ||= ContentMapping.find(:all)
    
    respond_to do |format|
      format.html
      format.xml  { render :xml => @content_mappings }
    end
  end

  def show
    @content_mapping = ContentMapping.find(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @content_mapping }
    end
  end

  def new
    @content_mapping = ContentMapping.new()
    @page = Page.find(params[:page_id]) if params[:page_id]
    @section = Section.find(params[:section_id]) if params[:section_id]

    @asset_type = AssetType.find_by_title(params[:asset_type].classify) if params[:asset_type]
    @asset_type ||= AssetType.find(params[:asset_type_id]) if params[:asset_type_id]
    @asset_class = @asset_type.title.constantize if @asset_type

    @asset = @asset_class.find(params[:asset_id]) if @asset_class && params[:asset_id]
    @asset ||= @asset_class.new if @asset_class

    @content_mapping.page = @page if @page
    @content_mapping.section = @section if @section
    @content_mapping.asset_type = @asset_type if @asset_type

    respond_to do |format|
      format.html
      # format.js { render :partial => "#{@asset_type.title.underscore.to_s.pluralize}/form", :layout => false}
      format.js { render :layout => false }
      format.xml { render :xml => @content_mapping }
    end
  end

  def edit
    @content_mapping = ContentMapping.find(params[:id])
  end

  def create
    params.reverse_merge! params[:content_mapping] if params[:content_mapping]
    page_id       = params[:page_id]
    section_id    = params[:section_id]
    asset_type_id = params[:asset_type_id]
    asset_id      = params[:asset_id]
    
    @content_mapping = ContentMapping.new(:page_id => params[:page_id],
                                          :section_id => params[:section_id],
                                          :asset_type_id => params[:asset_type_id])

    @asset_class = @content_mapping.asset_type.title.constantize
    @asset = @asset_class.find(params[:asset_id]) unless params[:asset_id].blank?
    @asset ||= @asset_class.create(params[@asset_class.name.tableize.singularize.to_sym])
    @page = @content_mapping.page
    
    @content_mapping.asset = @asset
    respond_to do |format|
      if @content_mapping.save && @asset.save
        flash[:notice] = "#{@content_mapping.asset.class.name.titleize}: #{@content_mapping.asset.title} was successfully added to #{@content_mapping.page.title} in the #{@content_mapping.section.title} section"
        format.html { redirect_to page_content_mappings_path(@content_mapping.page) }
        format.js { render @content_mapping, :layout => false, :locals => {:section => @content_mapping.section} }
        format.xml  { render :xml => @content_mapping, :status => :created, :location => @content_mapping }
      else
        format.html { render :action => "new" }
        format.js { render :update do |page| page.alert("Errors trying to attach this content: #{@content_mapping.errors.join(', ')}") end }
        format.xml  { render :xml => @content_mapping.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @content_mapping = ContentMapping.find(params[:id])

    respond_to do |format|
      if @content_mapping.update_attributes(params[:content_mapping])
        flash[:notice] = '#{@content_mapping.asset.class.name} was successfully updated.'
        format.html { redirect_to(@content_mapping.page) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @content_mapping.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @content_mapping = ContentMapping.find(params[:id])
    @page = @content_mapping.page
    @content_mapping.destroy

    respond_to do |format|
      format.html { redirect_to(page_content_mappings_path(@page)) }
      format.xml  { head :ok }
    end
  end
end
