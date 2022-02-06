module Precious
  module HasHistory
    VERSION_SHORT_HASH_RE = /[0-9a-f]{7,40}/

    def get_message_from_version(v)
      message = v.message.respond_to?(:force_encoding) ? v.message.force_encoding('UTF-8') : v.message
      CGI::escapeHTML(message)
    end

    def add_link_to_version_hash!(message)
        message.gsub!(VERSION_SHORT_HASH_RE) do |s|
            begin
              commit = @wiki.repo.git.lookup(s)
            rescue Rugged::OdbError, Rugged::ObjectError
              return s
            end
            version = Gollum::Git::Commit.new(commit)
            href = page_route("gollum/commit/#{version.id}")
            "<a href=#{href}>#{s}</a>"
        end
    end

    def version_author(v)
      User.new(v.author.name).uid
    end
  end
end
