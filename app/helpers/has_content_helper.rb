module HasContentHelper
  def page_icon(page)
    css_class = 'home_page' if page.root?
    css_class ||= page.children.empty? ? 'single_page' : 'parent_page'
    css_class
  end
  
  def navigation
    nav_list_for(@page)
  end
  
  def full_navigation
    nav_list_for(Page.root)
  end
  
  def nav_list_for(page)
    html = ""
    unless page.children.visible.empty?
      html << "<ul>"
      page.children.each do |child|
        html << "<li class='#{'active' if @page && child == @page || @page.ancestors.include?( child ) } #{'current' if @page && child == @page }'>"
        html << link_to( child.nav_title, child.permalink_path ) unless params[:mode]
        html << link_to( child.nav_title, surftoedit_path(child.id) ) if params[:mode]
        html << nav_list_for(child) if child.children
        html << "</li>"
      end
      html << "</ul>"
    end
    html
  end
  
  def determine_title_for(page)
    page.determine_title
  end
  
  def admin_bar
    render :partial => 'admin/bar'
  end
  
  def surf_to_edit?
    logged_in? && @mode == 'surftoedit'
  end
  
  def logged_in?
    current_user
  end  
  
  def surf_to_edit_controls_for(asset)
    render :partial => 'assets/surf_to_edit_controls', :locals => {:asset => asset}
  end
  
  def freightyard_includes
    render :partial => "admin/public_includes"
  end


  # def asset_tag_for(asset, &block)
   #   concat(content_tag(:div, capture(&block), :class => "surftoedit"))
   # end

   def asset_tag_for(asset, &block)
     block_to_partial("assets/tag", {:asset => asset}, &block)
   end

   def asset_edit_link_for(asset)
     link_to "Edit", edit_polymorphic_path(asset)
   end

   def block_to_partial(partial_name, options = {}, &block)
     options.merge!(:body => capture(&block))
     concat(render(:partial => partial_name, :locals => options))
   end

   def available_asset_types
     AssetType.all
   end

   def droppable_content_area(section, section_title)

     drop_receiving_element "section_#{section_title}_content", 
                             :url => page_section_content_mappings_path(@page, section, :asset_type => 'text_block', :asset_type_id => 1), 
                             :hoverclass => 'drag_hover',
                             :onDrop => "function(draggable_element, droppable_element, event) {

                                 asset_type = draggable_element.getAttribute('asset_type')
                                 section_id = droppable_element.getAttribute('section_id')
                                 asset_id   = draggable_element.getAttribute('asset_id')

                                 // Existing Asset
                                 if(draggable_element.hasClassName('existing_asset')){
                                   params     = parameters: 'asset_id='+asset_id+'&asset_type='+asset_type+'&section_id='+section_id+''
                                   url        = '/pages/#{@page.id}/sections/#{section.id}/content_mappings/new'

                                   new Ajax.Updater(droppable_element, url,
                                     {method: 'get', insertion: Insertion.Bottom, parameters: params}
                                   ) 
                                   // Modalbox.show(url+'&'params, {title: , width: 600, afterLoad: apply_behaviour}); return false;
                                 }

                                 // Fresh Asset
                                 if(draggable_element.hasClassName('asset_shelf')){
                                   url = '/pages/#{@page.id}/sections/#{section.id}/content_mappings/new'
                                   params = 'asset_type='+draggable_element.getAttribute('asset_type')+'&section_id='+droppable_element.getAttribute('section_id')+''

                                   new Ajax.Updater(droppable_element, url,
                                     {method: 'get', insertion: Insertion.Bottom, parameters: params}
                                   ) 
                                   // Modalbox.show(url+'&'params, {title: , width: 600, afterLoad: apply_behaviour}); return false;
                                 }
                               }"


   end

  
end

