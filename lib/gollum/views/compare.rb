require 'erb'
require 'gollum/diff'

module Precious
  module Views
    class Compare < Layout
      HEADER_CLASS = 'gc'
      ADDITION_CLASS = 'gi'
      REMOVAL_CLASS = 'gd'
      GIT_CLASS = 'gg'
      DEFAULT_CLASS = ''

      LINE_CHAR_ADD = '+'
      LINE_CHAR_REMOVE = '-'
      LINE_CHAR_NONE = ' '

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
        diff = Diff.new(diff).to_s

        lines = []
        lines_to_parse = diff.split("\n")[3..-1]
        lines_to_parse = lines_to_parse[2..-1] if lines_to_parse[0] =~ /^(---|rename to )/

        if lines_to_parse.nil? || lines_to_parse.empty?
          lines_to_parse = []  # File is created without content
        else
          lines_to_parse = lines_to_parse[1..-1] if lines_to_parse[0].start_with?('+++')
        end

        lines_to_parse.each_with_index do |line, line_index|
          ldln = left_diff_line_number(line)
          rdln = right_diff_line_number(line)
          line = ERB::Util.html_escape(line)
          klass = line_class(line)
          line = format_diff_line(line)
          lines << { :line  => line,
                     :class => klass,
                     :ldln  => ldln,
                     :rdln  => rdln }
        end
        lines
      end

      def show_revert
        !@message
      end

      # private

      def line_class(line)
        if line =~ /^@@/
          return HEADER_CLASS
        elsif git_line?(line)
          return GIT_CLASS
        end

        if line[0] == LINE_CHAR_ADD
          ADDITION_CLASS
        elsif line[0] == LINE_CHAR_REMOVE
          REMOVAL_CLASS
        else
          DEFAULT_CLASS
        end
      end

      def format_diff_line(line)
        if [LINE_CHAR_NONE, LINE_CHAR_ADD, LINE_CHAR_REMOVE].include? line[0]
          line = line[1..]
        end
        line.sub!(Diff::MARK, %{<span class="x">})
        line.sub!(Diff::MARK, %{</span>})
        line
      end

      @left_diff_line_number = nil

      def left_diff_line_number(line)
        if git_line?(line)
          m, li                  = *line.match(/\-(\d+)/)
          @left_diff_line_number = li.to_i
          @current_line_number   = @left_diff_line_number
          ret                    = '...'
        elsif removed_line?(line)
          ret                    = @left_diff_line_number.to_s
          @left_diff_line_number += 1
          @current_line_number   = @left_diff_line_number - 1
        elsif added_line?(line) || no_new_line_message?(line)
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
        if git_line?(line)
          m, ri                   = *line.match(/\+(\d+)/)
          @right_diff_line_number = ri.to_i
          @current_line_number    = @right_diff_line_number
          ret                     = '...'
        elsif removed_line?(line) || no_new_line_message?(line)
          ret = ' '
        elsif added_line?(line)
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
        (line[0] == ?+)
      end

      def removed_line?(line)
        (line[0] == ?-)
      end

      def no_new_line_message?(line)
        !!(line =~ /^\\ No newline at end of file$/)
      end

      def git_line?(line)
        !!(line =~ /^(\\ No newline|Binary files|@@)/)
      end
    end
  end
end
