module Princely
  module AssetSupport
    def localize_html_string(html_string, asset_path = nil)
      html_string = html_string.to_str
      # Make all paths relative, on disk paths...
      html_string.gsub!(".com:/",".com/") # strip out bad attachment_fu URLs
      html_string.gsub!( /src=["']+([^:]+?)["']/i ) do |m|
        asset_src = asset_path ? "#{asset_path}/#{$1}" : asset_file_path($1)
        %Q{src="#{asset_src}"} # re-route absolute paths
      end

      # Remove asset ids on images with a regex
      html_string.gsub!( /src=["'](\S+\?\d*)["']/i ) { |m| %Q{src="#{$1.split('?').first}"} }
      html_string
    end

    def asset_file_path(asset)
      asset = asset.gsub(%r'/assets/', '')

      if Rails.application.assets
        Rails.application.assets.find_asset(asset).try(:pathname) || asset
      else
        path = view_context.asset_path(asset.concat('.css')) # asset filename, inc. hash, with relative path
          .scan(%r"#{Regexp.escape(asset.split('.').first)}[-0-9a-f]*?\.[a-z]+?$")
          .first

        Rails.root.join('public/assets', path).to_s
      end
    end
  end
end
