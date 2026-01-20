require 'feedjira'
require 'httparty'
require 'jekyll'

module ExternalPosts
  class ExternalPostsGenerator < Jekyll::Generator
    safe true
    priority :high

    def generate(site)
      return if site.config['external_sources'].nil?

      site.config['external_sources'].each do |src|
        begin
          p "Fetching external posts from #{src['name']}:"
          
          response = HTTParty.get(src['rss_url'])
          
          # Check if the request was successful
          if response.code != 200
            p "!! Error fetching #{src['name']}: HTTP #{response.code}"
            next
          end

          xml = response.body
          feed = Feedjira.parse(xml)

          # Handle cases where Feedjira returns nil or doesn't have entries
          if feed.nil? || !feed.respond_to?(:entries)
            p "!! Could not parse XML for #{src['name']}. Skipping..."
            next
          end

          feed.entries.each do |e|
            p "...fetching #{e.url}"
            slug = e.title.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
            path = site.in_source_dir("_posts/#{slug}.md")
            
            doc = Jekyll::Document.new(
              path, { :site => site, :collection => site.collections['posts'] }
            )
            
            doc.data['external_source'] = src['name']
            doc.data['feed_content'] = e.content
            doc.data['title'] = "#{e.title}"
            doc.data['description'] = e.summary
            doc.data['date'] = e.published
            doc.data['redirect'] = e.url
            
            site.collections['posts'].docs << doc
          end
        rescue StandardError => error
          # This catches the "No valid parser" error and allows the build to continue
          p "!! Critical error with #{src['name']}: #{error.message}"
        end
      end
    end
  end
end
