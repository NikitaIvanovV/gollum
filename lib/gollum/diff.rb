module Precious
  class Diff
    MARK = "\f"

    def initialize(diff)
      @input = diff
      @output = ""
      clear()
    end

    def proc()
      @input.each_line do |line|
        if !@diff && line =~ /^@@/ then
          @diff = true
          @output += line
        elsif @diff && line[0] == "+" then
          @added.push line
          @added_removed.push line
        elsif @diff && line[0] == "-" then
          @removed.push line
          @added_removed.push line
        else
          proc_hunk()
          @output += line
        end
      end

      proc_hunk()
      return @output
    end

    alias_method :to_s, :proc

    private

    def clear()
      @added = []
      @removed = []
      @added_removed = []
    end

    def proc_hunk()
      if @added.length != @removed.length || @added.length < 1
        @added_removed.map { |a| @output += a }
      else
        highlight()
      end

      clear()
    end

    def highlight()
      prefix = suffix = 0

      add_rem = @added.zip(@removed)

      add_rem.map! do |a, b|
        min = [a.length, b.length].min

        i = 1
        while i < min do
          prefix = i
          break if a[i] != b[i]
          i += 1
        end

        i = 1
        while i <= min && prefix <= min - suffix do
          suffix = i
          break if a[-i] != b[-i]
          i += 1
        end

        a = insert_mark(a, prefix, suffix)
        b = insert_mark(b, prefix, suffix)

        [a, b]
      end

      add_rem.map { |a| @output += a[1] }
      add_rem.map { |a| @output += a[0] }
    end

    def insert_mark(s, prefix, suffix)
      n = s.length - suffix + 1

      return s if prefix == n

      s = s.insert(-suffix, MARK)
      s = s.insert(prefix,  MARK)
    end
  end
end
