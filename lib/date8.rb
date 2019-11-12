#require "date8/version"
require 'date'

module Date8
  class Error < StandardError; end

  class DatedFileTemplate

    INNTER_STRFTIME_TEMPLATE_MATCHER = /<(.*?)>/

    attr_reader :template, :matcher

    def initialize(template)
      self.template = template
    end

    def filename_for(date_ish)
      forgiving_dateify(date_ish).strftime(@strftime_template)
    end

    alias_method :at, :filename_for

    def now
      filename_for DateTime.now
    end

    alias_method :today, :now

    def tomorrow
      filename_for (DateTime.now + 1)
    end

    def yesterday
      filename_for (DateTime.now - 1)
    end

    def daily_since(date_ish)
      dt = forgiving_dateify(date_ish)
      if dt.to_date > DateTime.now.to_date
        []
      else
        daily_since(dt + 1).unshift(self.at(dt))
      end
    end

    def daily_through_yesterday(date_ish)
      daily_since(date_ish)[0..-2]
    end

    def daily_after(date_ish)
      daily_since(date_ish)[1..-1]
    end


    def template=(str)
      @template = str
      @matcher = template_matcher(template)
      @strftime_template = @template.gsub(/[<>]/, '')
    end

    def match?(str)
      @matcher.match? str
    end


    def forgiving_dateify(date_ish)
      if date_ish.respond_to? :to_datetime
        date_ish
      else
        str = date_ish.to_s
        parse_undelimited_datetime(str) or
        parse_delimited_datetime(str) or
        raise "Can't turn '#{str}' into a date-time'"
      end
    end


    def parse_undelimited_datetime(str)
      m = /\A(\d{4})(\d{2})(\d{2})(\d{2})?(\d{2})?(\d{2})?\Z/.match(str)
      m && DateTime.new(*(m[1..-1].map(&:to_i)))
    end

    def parse_delimited_datetime(str)

      # It's gotta start with four digits -- that's the year.
      unless str =~ /\A\d{4}/
        raise Error.new("'#{str}' doesn't obviously start with a year")
      end

      year = str[0..3]
      rest = str[4..-1]

      parts = rest.split(/[-_ :]/)
      unless parts.all? {|p| p =~ /\A\d*\Z/}
        raise Error.new("'#{str}' has non-digits between the delimiters")
      end

      # Only the year can have four digits. Split everything else into two
      parts = parts.map {|dstring| dstring.scan(/\d\d/)}.flatten
      parts.unshift(year)

      begin
        DateTime.new(*(parts.map(&:to_i)))
      rescue
        nil
      end
    end

    def template_matcher(template = @template)
      dt = DateTime.parse('1111-11-11T11:11:11:11')
      sample_date_expansion = dt.strftime extract_strftime_template(template)
      parts = sample_date_expansion.scan(/\d+|[^\d]+/).map{|pt| regexify_part(pt)}
      matcher_string = template.sub INNTER_STRFTIME_TEMPLATE_MATCHER, '(' + parts.join('') + ')'
      Regexp.new(matcher_string)
    rescue TypeError => e
      raise Error.new("Template must be of the form dddd<%Y%m%d>dddd where the stuff in angle brackets is a valid strftime template")
    end

    def regexify_part(pt)
      if pt =~ /1+/
        "\\d{#{pt.size}}"
      else
        pt
      end
    end

    def extract_strftime_template(template = @template)
      m = INNTER_STRFTIME_TEMPLATE_MATCHER.match(template)
      m ? m[1] : nil
    end

  end


  class DatedFileDirectory < DatedFileTemplate
    attr_reader :dir

    alias_method :path, :dir

    def initialize(template, dir='.')
      super(template)
      @dir = Pathname.new(dir)
    end


  end
end
