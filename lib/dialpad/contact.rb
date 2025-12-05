module Dialpad
  class Contact < DialpadObject
    class RequiredAttributeError < Dialpad::DialpadObject::RequiredAttributeError; end

    ATTRIBUTES = %i(
      company_name
      display_name
      emails
      extension
      first_name
      id
      job_title
      last_name
      owner_id
      phones
      primary_email
      primary_phone
      trunk_group
      type
      urls
    ).freeze

    def persisted?
      attributes[:id].present?
    end

    class << self
      include Validations

      # https://developers.dialpad.com/reference/contactsget
      def retrieve(id = nil)
        validate_required_attribute(id, "ID")

        response = Dialpad.client.get("contacts/#{id}")
        new(response.body)
      end

      # https://developers.dialpad.com/reference/contactslist
      def list(params = {})
        response = Dialpad.client.get('contacts', params)
        paginated_response_from(response)
      end

      # https://developers.dialpad.com/reference/contactscreate
      def create(attributes = {})
        validate_required_attributes(attributes, %i(first_name last_name))

        response = Dialpad.client.post('contacts', attributes)
        new(response.body)
      end

      # https://developers.dialpad.com/reference/contactscreate_with_uid
      def create_or_update(attributes = {})
        validate_required_attributes(attributes, %i(first_name last_name uid))

        response = Dialpad.client.put('contacts', attributes)
        new(response.body)
      end

      # https://developers.dialpad.com/reference/contactsupdate
      def update(id = nil, attributes = {})
        validate_required_attribute(id, "ID")

        response = Dialpad.client.patch("contacts/#{id}", attributes)
        new(response.body)
      end

      # https://developers.dialpad.com/reference/contactsdelete
      def destroy(id = nil)
        validate_required_attribute(id, "ID")

        response = Dialpad.client.delete("contacts/#{id}")
        new(response.body)
      end
    end
  end
end
