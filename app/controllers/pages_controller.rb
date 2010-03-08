class PagesController < AppController
  skip_before_filter :require_user, :only => :show
  # handles_sorting_of_nested_set
  
  def index
    @pages = Page.find(:all)
    @page = Page.root
    respond_to do |format|
      format.html
      format.xml  { render :xml => @pages }
    end
  end

  def show
    @page = find_page_with_scope
    
    perform_404 and return unless @page
    # perform_301 and return if @page.has_better_id?
    perform_redirect and return if @page.redirect
    
    

    respond_to do |format|
      format.html { render :layout => @page.layout }
      format.js { render :json => @page, :layout => false }
      format.xml  { render :xml => @page }
    end
    rescue
      perform_404 and return
  end

  def new
    @page = Page.new

    respond_to do |format|
      format.html
      format.xml  { render :xml => @page }
    end
  end

  def edit
    @page = Page.find(params[:id])
  end

  def create
    @page = Page.new(params[:page])
    
    respond_to do |format|
      if @page.save
        flash[:notice] = 'Page was successfully created.'
        format.html { redirect_to(pages_path) }
        format.xml  { render :xml => @page, :status => :created, :location => @page }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @page.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @page = Page.find(params[:id])

    respond_to do |format|
      if @page.update_attributes(params[:page])
        flash[:notice] = 'Page was successfully updated.'
        format.html { redirect_to(edit_page_path(@page.id)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @page.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @page = Page.find(params[:id])
    @page.destroy

    respond_to do |format|
      format.html { redirect_to(pages_url) }
      format.xml  { head :ok }
    end
  end
  
  # NON REST ACTIONS
  # =====================================================================
  
  def sort
      new_position = position_of(:moved_page_id).in_tree(:page_tree)
      @page = Page.find(params[:moved_page_id])
      @page.move_to_child_of(new_position[:parent])
      @page.move_to_left_of(new_position[:move_to_left_of])
      @page.save!
      # logger.info("New position of item #{params[:moved_page_id]}: " + new_position.inspect)
      render :update do |page|
        page.visual_effect :highlight, "page_#{params[:moved_page_id]}"
      end
  end
  
  def perform_404
    render :template => 'pages/missing', :status => 404, :layout => 'site'
  end
  
  def perform_301
    redirect_to @page, :status => :moved_permanently 
  end
  
  def perform_redirect
    redirect_to @page.redirect_url and return unless @page.redirect_url.blank?
    redirect_to page_path(@page.redirect_page_id) and return unless @page.redirect_page_id.blank?
  end  
  
  def find_page_with_scope
    if params[:id]
      page = Page.find(params[:id])
    elsif params[:path]
      if params[:path].empty?
        page = Page.root
      elsif params[:path].length > 1
        scope = params[:path][params[:path].length-2]
        page = Page.find(params[:path].last, :scope => scope) if scope
      else
        page ||= Page.find(params[:path].last, :scope => '')
      end
    else
      page = nil
    end
    page
  end
  
end
