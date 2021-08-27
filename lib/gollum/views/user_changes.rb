require_relative 'latest_changes.rb'

module Precious
  module Views
    class UserChanges < LatestChanges

      def title
        "User #{@username}"
      end

      def username
        @username
      end

    end
  end
end
