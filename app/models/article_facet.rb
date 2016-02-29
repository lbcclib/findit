class ArticleFacet
    attr_reader :title, :values

    def initialize title
        @title = title
        @values = Array.new
    end

    def add_value value, action, count
        tmp = Hash.new
        tmp[:value] = value
        tmp[:action] = action
        tmp[:count] = count
        @values.push(tmp)
    end
end
