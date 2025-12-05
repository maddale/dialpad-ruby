module Dialpad
  module Subscriptions
    class ContactEvent < DialpadObject
      class RequiredAttributeError < Dialpad::DialpadObject::RequiredAttributeError; end

      ATTRIBUTES = %i(
        contact_type
        enabled
        id
        webhook
        websocket
      ).freeze

      class << self
        include Validations

        # https://developers.dialpad.com/reference/webhook_contact_event_subscriptionget
        def retrieve(id = nil)
          validate_required_attribute(id, "ID")

          response = Dialpad.client.get("subscriptions/contact/#{id}")
          new(response.body)
        end

        # https://developers.dialpad.com/reference/webhook_contact_event_subscriptionlist
        def list(params = {})
          response = Dialpad.client.get('subscriptions/contact', params)
          paginated_response_from(response)
        end

        # https://developers.dialpad.com/reference/webhook_contact_event_subscriptioncreate
        def create(attributes = {})
          validate_required_attributes(attributes, [:webhook_id])

          response = Dialpad.client.post('subscriptions/contact', attributes)
          new(response.body)
        end

        # https://developers.dialpad.com/reference/webhook_contact_event_subscriptionupdate
        def update(id = nil, attributes = {})
          validate_required_attribute(id, "ID")

          response = Dialpad.client.patch("subscriptions/contact/#{id}", attributes)
          new(response.body)
        end

        # https://developers.dialpad.com/reference/webhook_contact_event_subscriptiondelete
        def destroy(id = nil)
          validate_required_attribute(id, "ID")

          response = Dialpad.client.delete("subscriptions/contact/#{id}")
          new(response.body)
        end
      end
    end
  end
end
