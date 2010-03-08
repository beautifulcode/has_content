ActionController::Routing::Routes.draw do |map|

  map.resources :images
  map.resources :text_blocks
  map.resources :flash_pieces

  map.resources :asset_types
  map.resources :page_templates
  map.resources :content_mappings
  map.resources :sections, :has_many => :content_mappings
  map.resources :pages, :collection => {:sort => :put}, :has_many => [:sections, :content_mappings, :pages]
  map.resources :pages do |page|
    page.resources :sections do |section|
      section.resources :content_mappings, :collection => {:sort => :post}
    end
  end
  map.connect "/pages/:parent_id/children/:action", :controller => 'pages'  
  map.new_content ":asset_type/:asset_id/:controller/:action"
  
  # CATCHALL ROUTE - For Pages. Provides path array via params
  # map.connect '*path', :controller => 'pages', :action => 'show'
end