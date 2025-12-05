module Dialpad
  PaginatedResponse = Struct.new(:cursor, :items)

  class DialpadObject
    class RequiredAttributeError < Dialpad::APIError; end

    attr_reader :attributes

    class << self
      def paginated_response_from(response)
        cursor = response.body['cursor']
        items =
          if response.body['items'].nil?
            []
          else
            response.body['items'].map { |item| new(item) }
          end

        PaginatedResponse.new(cursor, items)
      end
    end

    def initialize(attributes = {})
      @attributes =
        attributes.each_with_object({}) do |(key, value), hash|
          hash[key.to_sym] = value
        end
    end

    def method_missing(method, *args)
      if self.class::ATTRIBUTES.include?(method)
        @attributes[method]
      else
        super
      end
    end

    def respond_to_missing?(method, include_private = false)
      self.class::ATTRIBUTES.include?(method) || super
    end

    def update(attributes)
      self.class.update(id, attributes)
    end

    def destroy
      self.class.destroy(id)
    end
  end
end
