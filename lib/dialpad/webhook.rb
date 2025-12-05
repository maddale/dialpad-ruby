module Dialpad
  class Webhook < DialpadObject
    class RequiredAttributeError < Dialpad::DialpadObject::RequiredAttributeError; end

    ATTRIBUTES = %i(
      hook_url
      id
      signature
    ).freeze

    class << self
      include Validations

      # https://developers.dialpad.com/reference/webhooksget
      def retrieve(id = nil)
        validate_required_attribute(id, "ID")

        response = Dialpad.client.get("webhooks/#{id}")
        new(response.body)
      end

      # https://developers.dialpad.com/reference/webhookslist
      def list(params = {})
        response = Dialpad.client.get('webhooks', params)
        paginated_response_from(response)
      end

      # https://developers.dialpad.com/reference/webhookscreate
      def create(attributes)
        validate_required_attributes(attributes, [:hook_url])

        response = Dialpad.client.post('webhooks', attributes)
        new(response.body)
      end

      # https://developers.dialpad.com/reference/webhookupdate
      def update(id = nil, attributes = {})
        validate_required_attribute(id, "ID")

        response = Dialpad.client.patch("webhooks/#{id}", attributes)
        new(response.body)
      end

      # https://developers.dialpad.com/reference/webhooksdelete
      def destroy(id = nil)
        validate_required_attribute(id, "ID")

        response = Dialpad.client.delete("webhooks/#{id}")
        new(response.body)
      end
    end
  end
end
