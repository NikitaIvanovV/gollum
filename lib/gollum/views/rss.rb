require 'rss'

class RSSView
  
  include Precious::Views::AppHelpers
  include Precious::Views::RouteHelpers
  
  attr_reader :base_url
  
  def initialize(base_url, wiki_title, url, changes)
    @base_url = base_url
    @wiki_title = wiki_title
    @url = url
    @changes = changes
  end
  
  def render
    latest_changes = "#{@url}#{latest_changes_path}"
    RSS::Maker.make('2.0') do |maker|
      maker.channel.author = 'Gollum Wiki'
      maker.channel.updated = @changes.first.authored_date
      maker.channel.title = "#{@wiki_title} Latest Changes"
      maker.channel.description = "Latest Changes in #{@wiki_title}"
      maker.channel.link = latest_changes
      @changes.each do |change|
        maker.items.new_item do |item|
          item.link = latest_changes
          item.title = change.message
          item.updated = change.authored_date
          id = change.id
          files = change.stats.files.map do |files|
            [files[:old_file], files[:new_file]].compact.map do |file|
              f = extract_page_dir(file)
              "<li><a href=\"#{@url}#{page_route(f)}/#{id}\">#{f}</a></li>"
            end
          end
          user = Precious::User.new change.author.name
          author_name = user.username.nil? ? 'Unknown' : user.username
          item.description = "Commited by: #{author_name}<br/>Commit ID: <a href=\"#{@url}#{commit_path}/#{id}\">#{id[0..6]}</a><br/><br/>Affected files:<ul>#{files.join}</ul>"
        end
      end
    end.to_s
  end

end
