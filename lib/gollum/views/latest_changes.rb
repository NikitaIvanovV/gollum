module Precious
  module Views
    class LatestChanges < Layout
      DATE_FORMAT = '%B %d, %Y'

      include Pagination
      include HasUserIcons
      include HasHistory

      attr_reader :wiki

      def title
        "Latest Changes (Globally)"
      end

      def versions
        i = @versions.size + 1
        @versions.map do |v|
          i -= 1
          message = get_message_from_version(v)
          add_link_to_version_hash!(message)
          authored_date = v.authored_date
          { :id          => v.id,
            :id7         => v.id[0..6],
            :parent_id   => v.parent.nil? ? nil : v.parent.id,
            :href        => page_route("gollum/commit/#{v.id}"),
            :num         => i,
            :author      => v.author.name.respond_to?(:force_encoding) ? v.author.name.force_encoding('UTF-8') : v.author.name,
            :message     => message,
            :date_full   => authored_date,
            :date        => authored_date.strftime(DATE_FORMAT),
            :datetime    => authored_date.utc.iso8601,
            :date_format => DATE_FORMAT,
            :user_icon   => self.user_icon_code(v.author.email),
            :files       => v.stats.files.map { |f|
              new_path = extract_page_dir(f[:new_file])
              { :file => new_path,
                :link => "#{page_route(new_path)}/#{v.id}",
                :renamed => f[:old_file] ? extract_page_dir(f[:old_file]) : nil
              }
            }
          }
        end
      end

    end
  end
end
