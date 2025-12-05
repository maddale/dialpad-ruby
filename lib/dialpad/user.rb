module Dialpad
  class User < DialpadObject
    class RequiredAttributeError < Dialpad::DialpadObject::RequiredAttributeError; end

    ATTRIBUTES = %i(
      admin_office_ids
      company_id
      country
      date_active
      date_added
      date_first_login
      display_name
      do_not_disturb
      emails
      first_name
      group_details
      id
      image_url
      international_dialing_enabled
      is_admin
      is_available
      is_on_duty
      is_online
      is_super_admin
      language
      last_name
      license
      muted
      office_id
      onboarding_completed
      phone_numbers
      state
      timezone
      voicemail
    ).freeze

    class << self
      include Validations

      # https://developers.dialpad.com/reference/userslist
      def list(params = {})
        response = Dialpad.client.get('users', params)
        paginated_response_from(response)
      end

      # https://developers.dialpad.com/reference/usersget
      def retrieve(id = nil)
        validate_required_attribute(id, "ID")

        response = Dialpad.client.get("users/#{id}")
        new(response.body)
      end

      # https://developers.dialpad.com/reference/userscreate
      def create(attributes = {})
        validate_required_attributes(attributes, %i(email office_id))

        response = Dialpad.client.post('users', attributes)
        new(response.body)
      end

      # https://developers.dialpad.com/reference/usersupdate
      def update(id = nil, attributes = {})
        validate_required_attribute(id, "ID")

        response = Dialpad.client.patch("users/#{id}", attributes)
        new(response.body)
      end

      # https://developers.dialpad.com/reference/usersdelete
      def destroy(id = nil)
        validate_required_attribute(id, "ID")

        response = Dialpad.client.delete("users/#{id}")
        new(response.body)
      end
    end
  end
end
