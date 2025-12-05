module Dialpad
  class Call < DialpadObject
    class RequiredAttributeError < Dialpad::DialpadObject::RequiredAttributeError; end

    ATTRIBUTES = %i(
      admin_recording_urls
      call_id
      call_recording_ids
      callback_requested
      contact
      csat_score
      custom_data
      date_connected
      date_ended
      date_first_rang
      date_queued
      date_rang
      date_started
      direction
      duration
      entry_point_call_id
      entry_point_target
      event_timestamp
      external_number
      group_id
      hold_time
      internal_number
      integrations
      is_transferred
      labels
      master_call_id
      mos_score
      operator_call_id
      proxy_target
      recording_details
      routing_breadcrumbs
      state
      talk_time
      target
      target_availability_status
      total_duration
      transcription_text
      voicemail_link
      voicemail_recording_id
      was_recorded
    ).freeze

    class << self
      include Validations

      # https://developers.dialpad.com/reference/callget_call_info
      def retrieve(id = nil)
        validate_required_attribute(id, "ID")

        response = Dialpad.client.get("call/#{id}")
        new(response.body)
      end

      # https://developers.dialpad.com/reference/calllist
      def list(params = {})
        response = Dialpad.client.get('call', params)
        paginated_response_from(response)
      end

      # https://developers.dialpad.com/reference/callactionshangup
      def hangup!(id = nil)
        validate_required_attribute(id, "ID")
        response = Dialpad.client.put("call/#{id}/actions/hangup")

        if response.status.in?([200, 204])
          true
        else
          raise APIError, "#{response.status} - #{response.body}"
        end
      end
    end
  end
end
