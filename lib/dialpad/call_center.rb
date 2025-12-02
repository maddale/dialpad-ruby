module Dialpad
  class CallCenter < DialpadObject
    class RequiredAttributeError < Dialpad::DialpadObject::RequiredAttributeError; end

    ATTRIBUTES = %i(
      advanced_settings
      alerts
      availability_status
      country
      first_action
      friday_hours
      group_description
      hold_queue
      hours_on
      id
      monday_hours
      name
      no_operators_action
      office_id
      phone_numbers
      ring_seconds
      routing_options
      state
      thursday_hours
      timezone
      tuesday_hours
      voice_intelligence
      wednesday_hours
    ).freeze

    class << self
      include Validations

      # https://developers.dialpad.com/reference/callcentersget
      def retrieve(id = nil)
        validate_required_attribute(id, "ID")

        response = Dialpad.client.get("callcenters/#{id}")
        new(response.body)
      end

      # https://developers.dialpad.com/reference/callcenterslistall
      def list(params = {})
        response = Dialpad.client.get('callcenters', params)
        paginated_response_from(response)
      end

      # https://developers.dialpad.com/reference/callcenterscreate
      def create(attributes = {})
        validate_required_attributes(attributes, %i(name office_id))

        response = Dialpad.client.post('callcenters', attributes)
        new(response.body)
      end

      # https://developers.dialpad.com/reference/callcentersupdate
      def update(id = nil, attributes = {})
        validate_required_attribute(id, "ID")

        response = Dialpad.client.patch("callcenters/#{id}", attributes)
        new(response.body)
      end

      # https://developers.dialpad.com/reference/callcentersdelete
      def destroy(id = nil)
        validate_required_attribute(id, "ID")

        response = Dialpad.client.delete("callcenters/#{id}")
        new(response.body)
      end
    end
  end
end
