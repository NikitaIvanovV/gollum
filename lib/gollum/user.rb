module Precious
  class User
    attr_reader :uid

    def initialize(uid)
      @uid = uid
      @fetched_username = false
    end

    def self.set_username_converter(method)
      @@username_converter = method
    end

    def username
      if @fetched_username
        @username
      else
        @fetched_username = true
        @username = @@username_converter.call @uid
      end
    end

  end
end
