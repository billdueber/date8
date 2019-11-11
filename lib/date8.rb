require "date8/version"

module Date8
  class Error < StandardError; end

  class DatedFileTemplate
    def initialize(template)
      @template = template
    end
  end

end
