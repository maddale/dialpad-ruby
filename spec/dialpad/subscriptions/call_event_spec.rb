require 'spec_helper'

RSpec.describe Dialpad::Subscriptions::CallEvent do
  let(:base_url) { 'https://api.dialpad.com' }
  let(:token) { 'test_token' }
  let(:client) { Dialpad::Client.new(base_url: base_url, token: token) }

  before do
    allow(Dialpad).to receive(:client).and_return(client)
  end

  describe 'class methods' do
    describe '.retrieve' do
      context 'with valid ID' do
        let(:call_event_data) do
          {
            'call_states' => ['calling'],
            'enabled' => true,
            'group_calls_only' => false,
            'id' => '4614441776955392',
            'webhook' => {
              'hook_url' => 'https://example.com/webhooks/dialpad/call',
              'id' => '5159136949157888',
              'signature' => {
                'algo' => 'HS256',
                'secret' => 'test_secret',
                'type' => 'jwt'
              }
            }
          }
        end

        it 'retrieves a call event subscription by ID' do
          stub_request(:get, "#{base_url}/subscriptions/call/4614441776955392")
            .with(headers: { 'Authorization' => "Bearer #{token}" })
            .to_return(status: 200, body: call_event_data.to_json, headers: { 'Content-Type' => 'application/json' })

          call_event = described_class.retrieve('4614441776955392')

          expect(call_event).to be_a(described_class)
          expect(call_event.id).to eq('4614441776955392')
          expect(call_event.call_states).to eq(['calling'])
          expect(call_event.enabled).to be true
          expect(call_event.group_calls_only).to be false
          expect(call_event.webhook).to be_a(Hash)
          expect(call_event.webhook['hook_url']).to eq('https://example.com/webhooks/dialpad/call')
        end
      end

      context 'with invalid ID' do
        it 'raises RequiredAttributeError when ID is nil' do
          expect { described_class.retrieve(nil) }.to raise_error(
            Dialpad::Subscriptions::CallEvent::RequiredAttributeError,
            'Missing required attribute: ID'
          )
        end

        it 'raises RequiredAttributeError when ID is empty' do
          expect { described_class.retrieve('') }.to raise_error(
            Dialpad::Subscriptions::CallEvent::RequiredAttributeError,
            'Missing required attribute: ID'
          )
        end
      end
    end

    describe '.list' do
      context 'with call event subscriptions' do
        let(:call_events_data) do
          {
            'items' => [
              {
                'call_states' => ['calling'],
                'enabled' => true,
                'group_calls_only' => false,
                'id' => '4614441776955392',
                'webhook' => {
                  'hook_url' => 'https://example.com/webhooks/dialpad/call',
                  'id' => '5159136949157888',
                  'signature' => {
                    'algo' => 'HS256',
                    'secret' => 'secret1',
                    'type' => 'jwt'
                  }
                }
              },
              {
                'call_states' => ['completed', 'failed'],
                'enabled' => true,
                'group_calls_only' => true,
                'id' => '4614441776955393',
                'webhook' => {
                  'hook_url' => 'https://example.com/webhooks/dialpad/call2',
                  'id' => '5159136949157889',
                  'signature' => {
                    'algo' => 'HS256',
                    'secret' => 'secret2',
                    'type' => 'jwt'
                  }
                }
              }
            ]
          }
        end

        it 'returns a PaginatedResponse with items' do
          stub_request(:get, "#{base_url}/subscriptions/call")
            .with(headers: { 'Authorization' => "Bearer #{token}" })
            .to_return(status: 200, body: call_events_data.to_json, headers: { 'Content-Type' => 'application/json' })

          call_events = described_class.list

          expect(call_events).to be_a(Dialpad::PaginatedResponse)
          expect(call_events.items.length).to eq(2)
          expect(call_events.items.first).to be_a(described_class)
          expect(call_events.items.first.id).to eq('4614441776955392')
          expect(call_events.items.first.call_states).to eq(['calling'])
          expect(call_events.items.last.id).to eq('4614441776955393')
          expect(call_events.items.last.call_states).to eq(['completed', 'failed'])
          expect(call_events.items.last.group_calls_only).to be true
        end

        it 'passes query parameters to API' do
          params = { 'limit' => 10, 'offset' => 0 }
          stub_request(:get, "#{base_url}/subscriptions/call")
            .with(
              headers: { 'Authorization' => "Bearer #{token}" },
              query: params
            )
            .to_return(status: 200, body: call_events_data.to_json, headers: { 'Content-Type' => 'application/json' })

          described_class.list(params)
        end
      end

      context 'with no call event subscriptions' do
        it 'returns PaginatedResponse with empty items when items is blank' do
          stub_request(:get, "#{base_url}/subscriptions/call")
            .with(headers: { 'Authorization' => "Bearer #{token}" })
            .to_return(status: 200, body: { 'items' => [] }.to_json, headers: { 'Content-Type' => 'application/json' })

          call_events = described_class.list

          expect(call_events).to be_a(Dialpad::PaginatedResponse)
          expect(call_events.items).to eq([])
        end

        it 'returns PaginatedResponse with empty items when items is nil' do
          stub_request(:get, "#{base_url}/subscriptions/call")
            .with(headers: { 'Authorization' => "Bearer #{token}" })
            .to_return(status: 200, body: {}.to_json, headers: { 'Content-Type' => 'application/json' })

          call_events = described_class.list

          expect(call_events).to be_a(Dialpad::PaginatedResponse)
          expect(call_events.items).to eq([])
        end
      end
    end

    describe '.create' do
      let(:call_event_attributes) do
        {
          webhook_id: '5159136949157888',
          call_states: ['calling', 'completed'],
          group_calls_only: false
        }
      end

      let(:created_call_event_data) do
        {
          'call_states' => ['calling', 'completed'],
          'enabled' => true,
          'group_calls_only' => false,
          'id' => '4614441776955392',
          'webhook' => {
            'hook_url' => 'https://example.com/webhooks/dialpad/call',
            'id' => '5159136949157888',
            'signature' => {
              'algo' => 'HS256',
              'secret' => 'generated_secret',
              'type' => 'jwt'
            }
          }
        }
      end

      context 'with valid attributes' do
        it 'creates a new call event subscription' do
          stub_request(:post, "#{base_url}/subscriptions/call")
            .with(
              headers: { 'Authorization' => "Bearer #{token}" },
              body: call_event_attributes.to_json
            )
            .to_return(status: 201, body: created_call_event_data.to_json, headers: { 'Content-Type' => 'application/json' })

          call_event = described_class.create(call_event_attributes)

          expect(call_event).to be_a(described_class)
          expect(call_event.id).to eq('4614441776955392')
          expect(call_event.call_states).to eq(['calling', 'completed'])
          expect(call_event.enabled).to be true
          expect(call_event.group_calls_only).to be false
          expect(call_event.webhook).to be_a(Hash)
        end
      end

      context 'with missing required attributes' do
        it 'raises RequiredAttributeError when webhook_id is missing' do
          attributes = { call_states: ['calling'] }

          expect { described_class.create(attributes) }.to raise_error(
            Dialpad::Subscriptions::CallEvent::RequiredAttributeError,
            'Missing required attributes: webhook_id'
          )
        end

        it 'raises RequiredAttributeError when webhook_id is empty' do
          attributes = { webhook_id: '', call_states: ['calling'] }

          expect { described_class.create(attributes) }.to raise_error(
            Dialpad::Subscriptions::CallEvent::RequiredAttributeError,
            'Missing required attributes: webhook_id'
          )
        end

        it 'raises RequiredAttributeError when webhook_id is nil' do
          attributes = { webhook_id: nil, call_states: ['calling'] }

          expect { described_class.create(attributes) }.to raise_error(
            Dialpad::Subscriptions::CallEvent::RequiredAttributeError,
            'Missing required attributes: webhook_id'
          )
        end
      end
    end

    describe '.update' do
      let(:update_attributes) do
        {
          call_states: ['calling', 'completed', 'failed'],
          group_calls_only: true
        }
      end

      let(:updated_call_event_data) do
        {
          'call_states' => ['calling', 'completed', 'failed'],
          'enabled' => true,
          'group_calls_only' => true,
          'id' => '4614441776955392',
          'webhook' => {
            'hook_url' => 'https://example.com/webhooks/dialpad/call',
            'id' => '5159136949157888',
            'signature' => {
              'algo' => 'HS256',
              'secret' => 'updated_secret',
              'type' => 'jwt'
            }
          }
        }
      end

      context 'with valid ID and attributes' do
        it 'updates a call event subscription' do
          stub_request(:patch, "#{base_url}/subscriptions/call/4614441776955392")
            .with(
              headers: { 'Authorization' => "Bearer #{token}" },
              body: update_attributes.to_json
            )
            .to_return(status: 200, body: updated_call_event_data.to_json, headers: { 'Content-Type' => 'application/json' })

          call_event = described_class.update('4614441776955392', update_attributes)

          expect(call_event).to be_a(described_class)
          expect(call_event.id).to eq('4614441776955392')
          expect(call_event.call_states).to eq(['calling', 'completed', 'failed'])
          expect(call_event.group_calls_only).to be true
        end
      end
    end

    describe '.destroy' do
      let(:deleted_call_event_data) do
        {
          'call_states' => ['calling'],
          'enabled' => false,
          'group_calls_only' => false,
          'id' => '4614441776955392',
          'webhook' => {
            'hook_url' => 'https://example.com/webhooks/dialpad/call',
            'id' => '5159136949157888',
            'signature' => {
              'algo' => 'HS256',
              'secret' => 'deleted_secret',
              'type' => 'jwt'
            }
          }
        }
      end

      context 'with valid ID' do
        it 'deletes a call event subscription' do
          stub_request(:delete, "#{base_url}/subscriptions/call/4614441776955392")
            .with(headers: { 'Authorization' => "Bearer #{token}" })
            .to_return(status: 200, body: deleted_call_event_data.to_json, headers: { 'Content-Type' => 'application/json' })

          call_event = described_class.destroy('4614441776955392')

          expect(call_event).to be_a(described_class)
          expect(call_event.id).to eq('4614441776955392')
          expect(call_event.enabled).to be false
        end
      end

      context 'with invalid ID' do
        it 'raises RequiredAttributeError when ID is nil' do
          expect { described_class.destroy(nil) }.to raise_error(
            Dialpad::Subscriptions::CallEvent::RequiredAttributeError,
            'Missing required attribute: ID'
          )
        end

        it 'raises RequiredAttributeError when ID is empty' do
          expect { described_class.destroy('') }.to raise_error(
            Dialpad::Subscriptions::CallEvent::RequiredAttributeError,
            'Missing required attribute: ID'
          )
        end
      end
    end
  end

  describe 'instance methods' do
    let(:call_event_attributes) do
      {
        call_states: ['calling', 'completed'],
        enabled: true,
        group_calls_only: false,
        id: '4614441776955392',
        webhook: {
          hook_url: 'https://example.com/webhooks/dialpad/call',
          id: '5159136949157888',
          signature: {
            algo: 'HS256',
            secret: 'test_secret',
            type: 'jwt'
          }
        }
      }
    end

    let(:call_event) { described_class.new(call_event_attributes) }

    describe '#initialize' do
      it 'sets attributes from hash' do
        expect(call_event.call_states).to eq(['calling', 'completed'])
        expect(call_event.enabled).to be true
        expect(call_event.group_calls_only).to be false
        expect(call_event.id).to eq('4614441776955392')
        expect(call_event.webhook).to be_a(Hash)
        expect(call_event.webhook[:hook_url]).to eq('https://example.com/webhooks/dialpad/call')
        expect(call_event.webhook[:signature][:algo]).to eq('HS256')
      end

      it 'converts string keys to symbols' do
        call_event_with_string_keys = described_class.new(
          'call_states' => ['calling'],
          'enabled' => true,
          'group_calls_only' => false,
          'id' => '4614441776955392'
        )

        expect(call_event_with_string_keys.call_states).to eq(['calling'])
        expect(call_event_with_string_keys.enabled).to be true
        expect(call_event_with_string_keys.group_calls_only).to be false
        expect(call_event_with_string_keys.id).to eq('4614441776955392')
      end

      it 'handles empty attributes' do
        empty_call_event = described_class.new({})
        expect(empty_call_event.attributes).to eq({})
      end
    end

    describe 'attribute access' do
      it 'allows access to all defined attributes' do
        expect(call_event).to respond_to(:call_states)
        expect(call_event).to respond_to(:enabled)
        expect(call_event).to respond_to(:group_calls_only)
        expect(call_event).to respond_to(:id)
        expect(call_event).to respond_to(:webhook)
      end

      it 'raises NoMethodError for undefined attributes' do
        expect { call_event.undefined_attribute }.to raise_error(NoMethodError)
      end

      it 'responds to defined attributes' do
        expect(call_event.respond_to?(:call_states)).to be true
        expect(call_event.respond_to?(:enabled)).to be true
        expect(call_event.respond_to?(:group_calls_only)).to be true
        expect(call_event.respond_to?(:id)).to be true
        expect(call_event.respond_to?(:webhook)).to be true
      end

      it 'does not respond to undefined attributes' do
        expect(call_event.respond_to?(:undefined_attribute)).to be false
      end
    end

    describe 'call states handling' do
      let(:call_event_with_states) do
        described_class.new(
          call_states: ['calling', 'completed', 'failed', 'ringing'],
          enabled: true,
          group_calls_only: false,
          id: '4614441776955392'
        )
      end

      it 'handles multiple call states' do
        expect(call_event_with_states.call_states).to eq(['calling', 'completed', 'failed', 'ringing'])
        expect(call_event_with_states.call_states.length).to eq(4)
      end
    end

    describe 'webhook handling' do
      let(:call_event_with_webhook) do
        described_class.new(
          call_states: ['calling'],
          enabled: true,
          group_calls_only: false,
          id: '4614441776955392',
          webhook: {
            hook_url: 'https://example.com/webhooks/dialpad/call',
            id: '5159136949157888',
            signature: {
              algo: 'HS256',
              secret: 'my_secret_key',
              type: 'jwt'
            }
          }
        )
      end

      it 'handles webhook object' do
        expect(call_event_with_webhook.webhook).to be_a(Hash)
        expect(call_event_with_webhook.webhook[:hook_url]).to eq('https://example.com/webhooks/dialpad/call')
        expect(call_event_with_webhook.webhook[:id]).to eq('5159136949157888')
        expect(call_event_with_webhook.webhook[:signature]).to be_a(Hash)
        expect(call_event_with_webhook.webhook[:signature][:algo]).to eq('HS256')
      end
    end
  end

  describe 'constants' do
    it 'defines ATTRIBUTES constant' do
      expect(described_class::ATTRIBUTES).to be_an(Array)
      expect(described_class::ATTRIBUTES).to be_frozen
      expect(described_class::ATTRIBUTES).to include(:call_states, :enabled, :group_calls_only, :id, :webhook, :websocket)
    end

    it 'includes all expected call event attributes' do
      expected_attributes = %i(call_states enabled group_calls_only id webhook websocket)
      expect(described_class::ATTRIBUTES).to match_array(expected_attributes)
    end
  end

  describe 'error handling' do
    it 'defines RequiredAttributeError' do
      expect(Dialpad::Subscriptions::CallEvent::RequiredAttributeError).to be < Dialpad::DialpadObject::RequiredAttributeError
    end
  end

  describe 'API integration' do
    context 'when API returns error' do
      it 'handles 404 errors gracefully' do
        stub_request(:get, "#{base_url}/subscriptions/call/nonexistent")
          .with(headers: { 'Authorization' => "Bearer #{token}" })
          .to_return(status: 404, body: 'Not Found')

        expect { described_class.retrieve('nonexistent') }.to raise_error(Dialpad::APIError, /404 - Not Found/)
      end

      it 'handles 401 errors gracefully' do
        stub_request(:get, "#{base_url}/subscriptions/call/4614441776955392")
          .with(headers: { 'Authorization' => "Bearer #{token}" })
          .to_return(status: 401, body: 'Unauthorized')

        expect { described_class.retrieve('4614441776955392') }.to raise_error(Dialpad::APIError, /401 - Unauthorized/)
      end
    end
  end
end
