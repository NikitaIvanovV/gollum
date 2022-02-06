require_relative 'latest_changes.rb'

module Precious
  module Views
    class UserChanges < LatestChanges

      def title
        "User #{@username}"
      end

      def username
        User.new(@username).uid
      end

    end
  end
end
