module Dialpad
  module Subscriptions
    class CallEvent < DialpadObject
      class RequiredAttributeError < Dialpad::DialpadObject::RequiredAttributeError; end

      ATTRIBUTES = %i(
        call_states
        enabled
        group_calls_only
        id
        webhook
        websocket
      ).freeze

      # Response might contain webhook or websocket object
      def webhook
        attributes[:webhook]
      end

      def websocket
        attributes[:websocket]
      end

      class << self
        include Validations

        # https://developers.dialpad.com/reference/webhook_call_event_subscriptionget
        def retrieve(id = nil)
          validate_required_attribute(id, "ID")

          response = Dialpad.client.get("subscriptions/call/#{id}")
          new(response.body)
        end

        # https://developers.dialpad.com/reference/webhook_call_event_subscriptionlist
        def list(params = {})
          response = Dialpad.client.get('subscriptions/call', params)
          paginated_response_from(response)
        end

        # https://developers.dialpad.com/reference/webhook_call_event_subscriptioncreate
        def create(attributes = {})
          validate_required_attributes(attributes, [:webhook_id])

          response = Dialpad.client.post('subscriptions/call', attributes)
          new(response.body)
        end

        # https://developers.dialpad.com/reference/webhook_call_event_subscriptionupdate
        def update(id = nil, attributes = {})
          response = Dialpad.client.patch("subscriptions/call/#{id}", attributes)
          new(response.body)
        end

        # https://developers.dialpad.com/reference/webhook_call_event_subscriptiondelete
        def destroy(id = nil)
          validate_required_attribute(id, "ID")

          response = Dialpad.client.delete("subscriptions/call/#{id}")
          new(response.body)
        end
      end
    end
  end
end
