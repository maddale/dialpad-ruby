require 'spec_helper'

RSpec.describe Dialpad::Call do
  let(:base_url) { 'https://api.dialpad.com' }
  let(:token) { 'test_token' }
  let(:client) { Dialpad::Client.new(base_url: base_url, token: token) }

  before do
    allow(Dialpad).to receive(:client).and_return(client)
  end

  describe 'class methods' do
    describe '.retrieve' do
      context 'with valid ID' do
        let(:call_data) do
          {
            'call_id' => 5780678246121472,
            'direction' => 'outbound',
            'state' => 'calling',
            'duration' => nil,
            'date_started' => 1759338815163,
            'date_ended' => nil,
            'date_connected' => nil,
            'date_rang' => nil,
            'date_first_rang' => nil,
            'date_queued' => nil,
            'internal_number' => '+1234567890',
            'external_number' => '+0987654321',
            'was_recorded' => false,
            'transcription_text' => nil,
            'talk_time' => nil,
            'hold_time' => nil,
            'total_duration' => nil,
            'target_availability_status' => 'open',
            'callback_requested' => nil,
            'contact' => {
              'id' => 'shared_contact_pool_Company:1234567890123456_uid_001',
              'type' => 'shared',
              'email' => 'john.doe@example.com',
              'phone' => '+0987654321',
              'name' => 'John Doe'
            },
            'target' => {
              'id' => 1234567890123456,
              'type' => 'user',
              'email' => 'agent.smith@example.com',
              'phone' => '+1234567890',
              'name' => 'Agent Smith',
              'office_id' => 9876543210987654
            },
            'entry_point_call_id' => nil,
            'entry_point_target' => {},
            'operator_call_id' => nil,
            'proxy_target' => {},
            'group_id' => nil,
            'master_call_id' => nil,
            'is_transferred' => false,
            'csat_score' => nil,
            'routing_breadcrumbs' => [],
            'event_timestamp' => 1759338816268,
            'mos_score' => nil,
            'labels' => [],
            'voicemail_link' => nil,
            'voicemail_recording_id' => nil,
            'call_recording_ids' => [],
            'recording_details' => [],
            'integrations' => {}
          }
        end

        it 'retrieves a call by ID' do
          stub_request(:get, "#{base_url}/call/123")
            .with(headers: { 'Authorization' => "Bearer #{token}" })
            .to_return(status: 200, body: call_data.to_json, headers: { 'Content-Type' => 'application/json' })

          call = described_class.retrieve('123')

          expect(call).to be_a(described_class)
          expect(call.call_id).to eq(5780678246121472)
          expect(call.direction).to eq('outbound')
          expect(call.state).to eq('calling')
          expect(call.duration).to be_nil
          expect(call.was_recorded).to be false
          expect(call.date_started).to eq(1759338815163)
          expect(call.external_number).to eq('+0987654321')
          expect(call.internal_number).to eq('+1234567890')
          expect(call.target_availability_status).to eq('open')
        end
      end

      context 'with invalid ID' do
        it 'raises RequiredAttributeError when ID is nil' do
          expect { described_class.retrieve(nil) }.to raise_error(
            Dialpad::Call::RequiredAttributeError,
            'Missing required attribute: ID'
          )
        end

        it 'raises RequiredAttributeError when ID is empty' do
          expect { described_class.retrieve('') }.to raise_error(
            Dialpad::Call::RequiredAttributeError,
            'Missing required attribute: ID'
          )
        end
      end
    end

    describe '.list' do
      context 'with calls' do
        let(:calls_data) do
          {
            'items' => [
              {
                'call_id' => 5780678246121472,
                'direction' => 'outbound',
                'state' => 'calling',
                'duration' => nil,
                'date_started' => 1759338815163,
                'internal_number' => '+1234567890',
                'external_number' => '+0987654321',
                'was_recorded' => false,
                'contact' => {
                  'id' => 'shared_contact_pool_Company:1234567890123456_uid_001',
                  'type' => 'shared',
                  'name' => 'John Doe'
                },
                'target' => {
                  'id' => 1234567890123456,
                  'type' => 'user',
                  'name' => 'Agent Smith'
                }
              },
              {
                'call_id' => 5780678246121473,
                'direction' => 'inbound',
                'state' => 'completed',
                'duration' => 120,
                'date_started' => 1759338815164,
                'internal_number' => '+1234567890',
                'external_number' => '+1111111111',
                'was_recorded' => true,
                'contact' => {
                  'id' => 'shared_contact_pool_Company:1234567890123457_uid_002',
                  'type' => 'shared',
                  'name' => 'Jane Doe'
                },
                'target' => {
                  'id' => 1234567890123457,
                  'type' => 'user',
                  'name' => 'John Smith'
                }
              }
            ]
          }
        end

        it 'returns an array of calls' do
          stub_request(:get, "#{base_url}/call")
            .with(headers: { 'Authorization' => "Bearer #{token}" })
            .to_return(status: 200, body: calls_data.to_json, headers: { 'Content-Type' => 'application/json' })

          calls = described_class.list

          expect(calls).to be_a(Dialpad::PaginatedResponse)
          expect(calls.items.length).to eq(2)
          expect(calls.items.first).to be_a(described_class)
          expect(calls.items.first.call_id).to eq(5780678246121472)
          expect(calls.items.first.direction).to eq('outbound')
          expect(calls.items.first.state).to eq('calling')
          expect(calls.items.last.call_id).to eq(5780678246121473)
          expect(calls.items.last.direction).to eq('inbound')
          expect(calls.items.last.state).to eq('completed')
        end

        it 'passes query parameters to API' do
          params = { 'limit' => 10, 'offset' => 0, 'direction' => 'inbound' }
          stub_request(:get, "#{base_url}/call")
            .with(
              headers: { 'Authorization' => "Bearer #{token}" },
              query: params
            )
            .to_return(status: 200, body: calls_data.to_json, headers: { 'Content-Type' => 'application/json' })

          described_class.list(params)
          # WebMock automatically verifies the request was made with correct params
        end
      end

      context 'with no calls' do
        it 'returns PaginatedResponse with empty items when items is blank' do
          stub_request(:get, "#{base_url}/call")
            .with(headers: { 'Authorization' => "Bearer #{token}" })
            .to_return(status: 200, body: { 'items' => [] }.to_json, headers: { 'Content-Type' => 'application/json' })

          calls = described_class.list

          expect(calls).to be_a(Dialpad::PaginatedResponse)
          expect(calls.items).to eq([])
        end

        it 'returns PaginatedResponse with empty items when items is nil' do
          stub_request(:get, "#{base_url}/call")
            .with(headers: { 'Authorization' => "Bearer #{token}" })
            .to_return(status: 200, body: {}.to_json, headers: { 'Content-Type' => 'application/json' })

          calls = described_class.list

          expect(calls).to be_a(Dialpad::PaginatedResponse)
          expect(calls.items).to eq([])
        end
      end
    end
  end

  describe 'instance methods' do
    let(:call_attributes) do
      {
        call_id: 5780678246121472,
        direction: 'outbound',
        state: 'calling',
        duration: nil,
        date_started: 1759338815163,
        date_ended: nil,
        date_connected: nil,
        date_rang: nil,
        date_first_rang: nil,
        date_queued: nil,
        internal_number: '+1234567890',
        external_number: '+0987654321',
        was_recorded: false,
        is_transferred: false,
        transcription_text: nil,
        csat_score: nil,
        mos_score: nil,
        total_duration: nil,
        talk_time: nil,
        hold_time: nil,
        target_availability_status: 'open',
        callback_requested: nil,
        group_id: nil,
        operator_call_id: nil,
        master_call_id: nil,
        entry_point_call_id: nil,
        labels: [],
        routing_breadcrumbs: [],
        event_timestamp: 1759338816268,
        voicemail_link: nil,
        voicemail_recording_id: nil,
        call_recording_ids: [],
        recording_details: [],
        integrations: {},
        contact: {
          id: 'shared_contact_pool_Company:1234567890123456_uid_001',
          type: 'shared',
          email: 'john.doe@example.com',
          phone: '+0987654321',
          name: 'John Doe'
        },
        target: {
          id: 1234567890123456,
          type: 'user',
          email: 'agent.smith@example.com',
          phone: '+1234567890',
          name: 'Agent Smith',
          office_id: 9876543210987654
        },
        entry_point_target: {},
        proxy_target: {}
      }
    end

    let(:call) { described_class.new(call_attributes) }

    describe '#initialize' do
      it 'sets attributes from hash' do
        expect(call.call_id).to eq(5780678246121472)
        expect(call.direction).to eq('outbound')
        expect(call.state).to eq('calling')
        expect(call.duration).to be_nil
        expect(call.date_started).to eq(1759338815163)
        expect(call.date_ended).to be_nil
        expect(call.internal_number).to eq('+1234567890')
        expect(call.external_number).to eq('+0987654321')
        expect(call.was_recorded).to be false
        expect(call.is_transferred).to be false
        expect(call.transcription_text).to be_nil
        expect(call.csat_score).to be_nil
        expect(call.mos_score).to be_nil
        expect(call.labels).to eq([])
        expect(call.target_availability_status).to eq('open')
        expect(call.talk_time).to be_nil
        expect(call.hold_time).to be_nil
        expect(call.call_recording_ids).to eq([])
        expect(call.voicemail_link).to be_nil
        expect(call.contact).to be_a(Hash)
        expect(call.target).to be_a(Hash)
      end

      it 'converts string keys to symbols' do
        call_with_string_keys = described_class.new(
          'call_id' => 5780678246121472,
          'direction' => 'outbound',
          'state' => 'calling'
        )

        expect(call_with_string_keys.call_id).to eq(5780678246121472)
        expect(call_with_string_keys.direction).to eq('outbound')
        expect(call_with_string_keys.state).to eq('calling')
      end

      it 'handles empty attributes' do
        empty_call = described_class.new({})
        expect(empty_call.attributes).to eq({})
      end
    end

    describe 'attribute access' do
      it 'allows access to all defined attributes' do
        expect(call).to respond_to(:call_id)
        expect(call).to respond_to(:direction)
        expect(call).to respond_to(:state)
        expect(call).to respond_to(:duration)
        expect(call).to respond_to(:date_started)
        expect(call).to respond_to(:date_ended)
        expect(call).to respond_to(:date_connected)
        expect(call).to respond_to(:date_rang)
        expect(call).to respond_to(:date_first_rang)
        expect(call).to respond_to(:date_queued)
        expect(call).to respond_to(:internal_number)
        expect(call).to respond_to(:external_number)
        expect(call).to respond_to(:was_recorded)
        expect(call).to respond_to(:transcription_text)
        expect(call).to respond_to(:csat_score)
        expect(call).to respond_to(:mos_score)
        expect(call).to respond_to(:labels)
        expect(call).to respond_to(:talk_time)
        expect(call).to respond_to(:hold_time)
        expect(call).to respond_to(:target_availability_status)
        expect(call).to respond_to(:callback_requested)
        expect(call).to respond_to(:call_recording_ids)
        expect(call).to respond_to(:voicemail_link)
        expect(call).to respond_to(:voicemail_recording_id)
        expect(call).to respond_to(:contact)
        expect(call).to respond_to(:target)
        expect(call).to respond_to(:integrations)
      end

      it 'raises NoMethodError for undefined attributes' do
        expect { call.undefined_attribute }.to raise_error(NoMethodError)
      end
    end
  end

  describe 'error handling' do
    it 'defines RequiredAttributeError' do
      expect(Dialpad::Call::RequiredAttributeError).to be < Dialpad::DialpadObject::RequiredAttributeError
    end
  end

  describe 'API integration' do
    context 'when API returns error' do
      it 'handles 404 errors gracefully' do
        stub_request(:get, "#{base_url}/call/nonexistent")
          .with(headers: { 'Authorization' => "Bearer #{token}" })
          .to_return(status: 404, body: 'Not Found')

        expect { described_class.retrieve('nonexistent') }.to raise_error(Dialpad::APIError, /404 - Not Found/)
      end

      it 'handles 401 errors gracefully' do
        stub_request(:get, "#{base_url}/call/123")
          .with(headers: { 'Authorization' => "Bearer #{token}" })
          .to_return(status: 401, body: 'Unauthorized')

        expect { described_class.retrieve('123') }.to raise_error(Dialpad::APIError, /401 - Unauthorized/)
      end
    end
  end
end
