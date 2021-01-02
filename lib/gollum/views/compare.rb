require 'erb'

module Precious
  module Views
    class Compare < Layout
      HEADER_CLASS = 'gc'
      ADDITION_CLASS = 'gi'
      REMOVAL_CLASS = 'gd'
      DEFAULT_CLASS = ''

      include HasPage

      attr_reader :page, :diff, :versions, :message, :allow_editing

      def title
        "Comparison of #{@page.title}"
      end

      def before
        @versions[0][0..6]
      end

      def after
        @versions[1][0..6]
      end

      def lines(diff = @diff)
        lines = []
        lines_to_parse = diff.split("\n")[4..-1]

        # If the diff is of a rename, the diff header will be one line longer than normal because it will contain a line starting with '+++' to indicate the 'new' filename.
        # Make sure to skip that header line if it is present.
        lines_to_parse = lines_to_parse[1..-1] if lines_to_parse[0].start_with?('+++')

        lines_to_parse.each_with_index do |line, line_index|
          ldln = left_diff_line_number(line)
          rdln = right_diff_line_number(line)
          line = ERB::Util.html_escape(line)
          line = add_color_span(line) if @word_diff
          lines << { :line  => line,
                     :class => line_class(line),
                     :ldln  => ldln,
                     :rdln  => rdln }
        end if diff
        lines
      end

      def show_revert
        !@message
      end

      # private

      def line_class(line)
        if line =~ /^@@/
          return HEADER_CLASS
        end

        return DEFAULT_CLASS if @word_diff

        if line =~ /^\+/
          ADDITION_CLASS
        elsif line =~ /^\-/
          REMOVAL_CLASS
        else
          DEFAULT_CLASS
        end
      end

      ADDITION_START = '{+'
      ADDITION_END = '+}'
      REMOVAL_START = '[-'
      REMOVAL_END = '-]'

      def add_color_span(line)
        line = line.dup
        line.gsub!(ADDITION_START, "<span class=#{ADDITION_CLASS}>")
        line.gsub!(REMOVAL_START, "<span class=#{REMOVAL_CLASS}>")
        line.gsub!(ADDITION_END, "</span>")
        line.gsub!(REMOVAL_END, "</span>")
        line
      end

      @left_diff_line_number = nil

      def left_diff_line_number(line)
        if line =~ /^@@/
          m, li                  = *line.match(/\-(\d+)/)
          @left_diff_line_number = li.to_i
          @current_line_number   = @left_diff_line_number
          ret                    = '...'
        elsif removed_line? line
          ret                    = @left_diff_line_number.to_s
          @left_diff_line_number += 1
          @current_line_number   = @left_diff_line_number - 1
        elsif added_line? line
          ret = ' '
        else
          ret                    = @left_diff_line_number.to_s
          @left_diff_line_number += 1
          @current_line_number   = @left_diff_line_number - 1
        end
        ret
      end

      @right_diff_line_number = nil

      def right_diff_line_number(line)
        if line =~ /^@@/
          m, ri                   = *line.match(/\+(\d+)/)
          @right_diff_line_number = ri.to_i
          @current_line_number    = @right_diff_line_number
          ret                     = '...'
        elsif removed_line? line
          ret = ' '
        elsif added_line? line
          ret                     = @right_diff_line_number.to_s
          @right_diff_line_number += 1
          @current_line_number    = @right_diff_line_number - 1
        else
          ret                     = @right_diff_line_number.to_s
          @right_diff_line_number += 1
          @current_line_number    = @right_diff_line_number - 1
        end
        ret
      end

      def added_line?(line)
        if @word_diff
          line =~ /(^ {\+.+\+}$|^{\+)/
        else
          line[0] == ?+
        end
      end

      def removed_line?(line)
        if @word_diff
          line =~ /(^ \[-.+-\]$|^\[)/
        else
          line[0] == ?-
        end
      end

    end
  end
end
