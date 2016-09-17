class ArticleFacet
    attr_reader :title, :values

    # Create a new facet
    def initialize title
        @title = title
        @values = Array.new
    end

    # Add a new value to an existing facet
    def add_value value, action, count
        tmp = Hash.new
        tmp[:value] = value
        tmp[:action] = action
        tmp[:count] = count
        @values.push(tmp)
    end
end
