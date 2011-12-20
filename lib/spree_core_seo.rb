require 'spree_core'
require 'core_seo_hooks'

module SpreeCoreSeo
  class Engine < Rails::Engine

    config.autoload_paths += %W(#{config.root}/lib)

    def self.activate

    	Spree::BaseHelper.module_eval do       
      	# Override meta tags for homepage
      	def meta_data_tags
        	# if product index, then it's the homepage, so lets add the defaults
        	if defined?(request) and request.fullpath == "/"
          	"".tap do |tags|
            	if Spree::Config[:homepage_meta_keywords] and Spree::Config[:homepage_meta_keywords].present?                         
              	tags << tag('meta', :name => 'keywords', :content => Spree::Config[:homepage_meta_keywords]) + "\n"
            	end
            	if Spree::Config[:homepage_meta_description] and Spree::Config[:homepage_meta_description].present?
              	tags << tag('meta', :name => 'description', :content => Spree::Config[:homepage_meta_description]) + "\n"           
            	end                            
          	end                              
        	else
            object = instance_variable_get('@'+controller_name.singularize)
            return unless object
          	"".tap do |tags|
            	if object.respond_to?(:meta_keywords) and object.meta_keywords.present?
              	tags << tag('meta', :name => 'keywords', :content => object.meta_keywords.html_safe) + "\n"
            	end
            	if object.respond_to?(:meta_description) and object.meta_description.present?
              	tags << tag('meta', :name => 'description', :content => object.meta_description.html_safe) + "\n"
            	end
          	end
        	end
      	end
    	end
      
      ProductsController.class_eval do
        def accurate_title
          if @product && defined?(@product.title_tag) && @product.title_tag.present?
            @product.title_tag.html_safe
          elsif @product
            @product.name
          elsif defined?(request) and request.fullpath == "/"
            Spree::Config[:homepage_title] if Spree::Config[:homepage_title].present?
          end
        end
      end

      TaxonsController.class_eval do
        def accurate_title
          if defined?(@taxon.title_tag) && @taxon.title_tag.present?
            @taxon.title_tag
          else
            @taxon.name
          end
        end
      end

      Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")) do |c|
        Rails.env.production? ? require(c) : load(c)
      end
    end

    config.to_prepare &method(:activate).to_proc
  end
end
