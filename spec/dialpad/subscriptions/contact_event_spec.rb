require 'spec_helper'

RSpec.describe Dialpad::Subscriptions::ContactEvent do
  let(:base_url) { 'https://api.dialpad.com' }
  let(:token) { 'test_token' }
  let(:client) { Dialpad::Client.new(base_url: base_url, token: token) }

  before do
    allow(Dialpad).to receive(:client).and_return(client)
  end

  describe 'class methods' do
    describe '.retrieve' do
      context 'with valid ID' do
        let(:contact_event_data) do
          {
            'contact_type' => 'shared',
            'enabled' => true,
            'id' => '5923790016724992',
            'webhook' => {
              'hook_url' => 'https://example.com/webhooks/dialpad/contact',
              'id' => '5428295198556160',
              'signature' => {
                'algo' => 'HS256',
                'secret' => 'test_secret',
                'type' => 'jwt'
              }
            }
          }
        end

        it 'retrieves a contact event subscription by ID' do
          stub_request(:get, "#{base_url}/subscriptions/contact/5923790016724992")
            .with(headers: { 'Authorization' => "Bearer #{token}" })
            .to_return(status: 200, body: contact_event_data.to_json, headers: { 'Content-Type' => 'application/json' })

          contact_event = described_class.retrieve('5923790016724992')

          expect(contact_event).to be_a(described_class)
          expect(contact_event.id).to eq('5923790016724992')
          expect(contact_event.contact_type).to eq('shared')
          expect(contact_event.enabled).to be true
          expect(contact_event.webhook).to be_a(Hash)
          expect(contact_event.webhook['hook_url']).to eq('https://example.com/webhooks/dialpad/contact')
        end
      end

      context 'with invalid ID' do
        it 'raises RequiredAttributeError when ID is nil' do
          expect { described_class.retrieve(nil) }.to raise_error(
            Dialpad::Subscriptions::ContactEvent::RequiredAttributeError,
            'Missing required attribute: ID'
          )
        end

        it 'raises RequiredAttributeError when ID is empty' do
          expect { described_class.retrieve('') }.to raise_error(
            Dialpad::Subscriptions::ContactEvent::RequiredAttributeError,
            'Missing required attribute: ID'
          )
        end
      end
    end

    describe '.list' do
      context 'with contact event subscriptions' do
        let(:contact_events_data) do
          {
            'items' => [
              {
                'contact_type' => 'shared',
                'enabled' => true,
                'id' => '5923790016724992',
                'webhook' => {
                  'hook_url' => 'https://example.com/webhooks/dialpad/contact',
                  'id' => '5428295198556160',
                  'signature' => {
                    'algo' => 'HS256',
                    'secret' => 'secret1',
                    'type' => 'jwt'
                  }
                }
              },
              {
                'contact_type' => 'user',
                'enabled' => true,
                'id' => '5923790016724993',
                'webhook' => {
                  'hook_url' => 'https://example.com/webhooks/dialpad/contact2',
                  'id' => '5428295198556161',
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
          stub_request(:get, "#{base_url}/subscriptions/contact")
            .with(headers: { 'Authorization' => "Bearer #{token}" })
            .to_return(status: 200, body: contact_events_data.to_json, headers: { 'Content-Type' => 'application/json' })

          contact_events = described_class.list

          expect(contact_events).to be_a(Dialpad::PaginatedResponse)
          expect(contact_events.items.length).to eq(2)
          expect(contact_events.items.first).to be_a(described_class)
          expect(contact_events.items.first.id).to eq('5923790016724992')
          expect(contact_events.items.first.contact_type).to eq('shared')
          expect(contact_events.items.last.id).to eq('5923790016724993')
          expect(contact_events.items.last.contact_type).to eq('user')
        end

        it 'passes query parameters to API' do
          params = { 'limit' => 10, 'offset' => 0 }
          stub_request(:get, "#{base_url}/subscriptions/contact")
            .with(
              headers: { 'Authorization' => "Bearer #{token}" },
              query: params
            )
            .to_return(status: 200, body: contact_events_data.to_json, headers: { 'Content-Type' => 'application/json' })

          described_class.list(params)
        end
      end

      context 'with no contact event subscriptions' do
        it 'returns PaginatedResponse with empty items when items is blank' do
          stub_request(:get, "#{base_url}/subscriptions/contact")
            .with(headers: { 'Authorization' => "Bearer #{token}" })
            .to_return(status: 200, body: { 'items' => [] }.to_json, headers: { 'Content-Type' => 'application/json' })

          contact_events = described_class.list

          expect(contact_events).to be_a(Dialpad::PaginatedResponse)
          expect(contact_events.items).to eq([])
        end

        it 'returns PaginatedResponse with empty items when items is nil' do
          stub_request(:get, "#{base_url}/subscriptions/contact")
            .with(headers: { 'Authorization' => "Bearer #{token}" })
            .to_return(status: 200, body: {}.to_json, headers: { 'Content-Type' => 'application/json' })

          contact_events = described_class.list

          expect(contact_events).to be_a(Dialpad::PaginatedResponse)
          expect(contact_events.items).to eq([])
        end
      end
    end

    describe '.create' do
      let(:contact_event_attributes) do
        {
          webhook_id: '5428295198556160',
          contact_type: 'shared'
        }
      end

      let(:created_contact_event_data) do
        {
          'contact_type' => 'shared',
          'enabled' => true,
          'id' => '5923790016724992',
          'webhook' => {
            'hook_url' => 'https://example.com/webhooks/dialpad/contact',
            'id' => '5428295198556160',
            'signature' => {
              'algo' => 'HS256',
              'secret' => 'generated_secret',
              'type' => 'jwt'
            }
          }
        }
      end

      context 'with valid attributes' do
        it 'creates a new contact event subscription' do
          stub_request(:post, "#{base_url}/subscriptions/contact")
            .with(
              headers: { 'Authorization' => "Bearer #{token}" },
              body: contact_event_attributes.to_json
            )
            .to_return(status: 201, body: created_contact_event_data.to_json, headers: { 'Content-Type' => 'application/json' })

          contact_event = described_class.create(contact_event_attributes)

          expect(contact_event).to be_a(described_class)
          expect(contact_event.id).to eq('5923790016724992')
          expect(contact_event.contact_type).to eq('shared')
          expect(contact_event.enabled).to be true
          expect(contact_event.webhook).to be_a(Hash)
        end
      end

      context 'with missing required attributes' do
        it 'raises RequiredAttributeError when webhook_id is missing' do
          attributes = { contact_type: 'shared' }

          expect { described_class.create(attributes) }.to raise_error(
            Dialpad::Subscriptions::ContactEvent::RequiredAttributeError,
            'Missing required attributes: webhook_id'
          )
        end

        it 'raises RequiredAttributeError when webhook_id is empty' do
          attributes = { webhook_id: '', contact_type: 'shared' }

          expect { described_class.create(attributes) }.to raise_error(
            Dialpad::Subscriptions::ContactEvent::RequiredAttributeError,
            'Missing required attributes: webhook_id'
          )
        end

        it 'raises RequiredAttributeError when webhook_id is nil' do
          attributes = { webhook_id: nil, contact_type: 'shared' }

          expect { described_class.create(attributes) }.to raise_error(
            Dialpad::Subscriptions::ContactEvent::RequiredAttributeError,
            'Missing required attributes: webhook_id'
          )
        end
      end
    end

    describe '.update' do
      let(:update_attributes) do
        {
          contact_type: 'user',
          enabled: false
        }
      end

      let(:updated_contact_event_data) do
        {
          'contact_type' => 'user',
          'enabled' => false,
          'id' => '5923790016724992',
          'webhook' => {
            'hook_url' => 'https://example.com/webhooks/dialpad/contact',
            'id' => '5428295198556160',
            'signature' => {
              'algo' => 'HS256',
              'secret' => 'updated_secret',
              'type' => 'jwt'
            }
          }
        }
      end

      context 'with valid ID and attributes' do
        it 'updates a contact event subscription' do
          stub_request(:patch, "#{base_url}/subscriptions/contact/5923790016724992")
            .with(
              headers: { 'Authorization' => "Bearer #{token}" },
              body: update_attributes.to_json
            )
            .to_return(status: 200, body: updated_contact_event_data.to_json, headers: { 'Content-Type' => 'application/json' })

          contact_event = described_class.update('5923790016724992', update_attributes)

          expect(contact_event).to be_a(described_class)
          expect(contact_event.id).to eq('5923790016724992')
          expect(contact_event.contact_type).to eq('user')
          expect(contact_event.enabled).to be false
        end
      end

      context 'with invalid ID' do
        it 'raises RequiredAttributeError when ID is nil' do
          expect { described_class.update(nil, update_attributes) }.to raise_error(
            Dialpad::Subscriptions::ContactEvent::RequiredAttributeError,
            'Missing required attribute: ID'
          )
        end

        it 'raises RequiredAttributeError when ID is empty' do
          expect { described_class.update('', update_attributes) }.to raise_error(
            Dialpad::Subscriptions::ContactEvent::RequiredAttributeError,
            'Missing required attribute: ID'
          )
        end
      end
    end

    describe '.destroy' do
      let(:deleted_contact_event_data) do
        {
          'contact_type' => 'shared',
          'enabled' => false,
          'id' => '5923790016724992',
          'webhook' => {
            'hook_url' => 'https://example.com/webhooks/dialpad/contact',
            'id' => '5428295198556160',
            'signature' => {
              'algo' => 'HS256',
              'secret' => 'deleted_secret',
              'type' => 'jwt'
            }
          }
        }
      end

      context 'with valid ID' do
        it 'deletes a contact event subscription' do
          stub_request(:delete, "#{base_url}/subscriptions/contact/5923790016724992")
            .with(headers: { 'Authorization' => "Bearer #{token}" })
            .to_return(status: 200, body: deleted_contact_event_data.to_json, headers: { 'Content-Type' => 'application/json' })

          contact_event = described_class.destroy('5923790016724992')

          expect(contact_event).to be_a(described_class)
          expect(contact_event.id).to eq('5923790016724992')
          expect(contact_event.enabled).to be false
        end
      end

      context 'with invalid ID' do
        it 'raises RequiredAttributeError when ID is nil' do
          expect { described_class.destroy(nil) }.to raise_error(
            Dialpad::Subscriptions::ContactEvent::RequiredAttributeError,
            'Missing required attribute: ID'
          )
        end

        it 'raises RequiredAttributeError when ID is empty' do
          expect { described_class.destroy('') }.to raise_error(
            Dialpad::Subscriptions::ContactEvent::RequiredAttributeError,
            'Missing required attribute: ID'
          )
        end
      end
    end
  end

  describe 'instance methods' do
    let(:contact_event_attributes) do
      {
        contact_type: 'shared',
        enabled: true,
        id: '5923790016724992',
        webhook: {
          hook_url: 'https://example.com/webhooks/dialpad/contact',
          id: '5428295198556160',
          signature: {
            algo: 'HS256',
            secret: 'test_secret',
            type: 'jwt'
          }
        }
      }
    end

    let(:contact_event) { described_class.new(contact_event_attributes) }

    describe '#initialize' do
      it 'sets attributes from hash' do
        expect(contact_event.contact_type).to eq('shared')
        expect(contact_event.enabled).to be true
        expect(contact_event.id).to eq('5923790016724992')
        expect(contact_event.webhook).to be_a(Hash)
        expect(contact_event.webhook[:hook_url]).to eq('https://example.com/webhooks/dialpad/contact')
        expect(contact_event.webhook[:signature][:algo]).to eq('HS256')
      end

      it 'converts string keys to symbols' do
        contact_event_with_string_keys = described_class.new(
          'contact_type' => 'user',
          'enabled' => true,
          'id' => '5923790016724992'
        )

        expect(contact_event_with_string_keys.contact_type).to eq('user')
        expect(contact_event_with_string_keys.enabled).to be true
        expect(contact_event_with_string_keys.id).to eq('5923790016724992')
      end

      it 'handles empty attributes' do
        empty_contact_event = described_class.new({})
        expect(empty_contact_event.attributes).to eq({})
      end
    end

    describe 'attribute access' do
      it 'allows access to all defined attributes' do
        expect(contact_event).to respond_to(:contact_type)
        expect(contact_event).to respond_to(:enabled)
        expect(contact_event).to respond_to(:id)
        expect(contact_event).to respond_to(:webhook)
      end

      it 'raises NoMethodError for undefined attributes' do
        expect { contact_event.undefined_attribute }.to raise_error(NoMethodError)
      end

      it 'responds to defined attributes' do
        expect(contact_event.respond_to?(:contact_type)).to be true
        expect(contact_event.respond_to?(:enabled)).to be true
        expect(contact_event.respond_to?(:id)).to be true
        expect(contact_event.respond_to?(:webhook)).to be true
      end

      it 'does not respond to undefined attributes' do
        expect(contact_event.respond_to?(:undefined_attribute)).to be false
      end
    end

    describe 'contact type handling' do
      let(:contact_event_with_type) do
        described_class.new(
          contact_type: 'user',
          enabled: true,
          id: '5923790016724992'
        )
      end

      it 'handles different contact types' do
        expect(contact_event_with_type.contact_type).to eq('user')
      end
    end

    describe 'webhook handling' do
      let(:contact_event_with_webhook) do
        described_class.new(
          contact_type: 'shared',
          enabled: true,
          id: '5923790016724992',
          webhook: {
            hook_url: 'https://example.com/webhooks/dialpad/contact',
            id: '5428295198556160',
            signature: {
              algo: 'HS256',
              secret: 'my_secret_key',
              type: 'jwt'
            }
          }
        )
      end

      it 'handles webhook object' do
        expect(contact_event_with_webhook.webhook).to be_a(Hash)
        expect(contact_event_with_webhook.webhook[:hook_url]).to eq('https://example.com/webhooks/dialpad/contact')
        expect(contact_event_with_webhook.webhook[:id]).to eq('5428295198556160')
        expect(contact_event_with_webhook.webhook[:signature]).to be_a(Hash)
        expect(contact_event_with_webhook.webhook[:signature][:algo]).to eq('HS256')
      end
    end
  end

  describe 'error handling' do
    it 'defines RequiredAttributeError' do
      expect(Dialpad::Subscriptions::ContactEvent::RequiredAttributeError).to be < Dialpad::DialpadObject::RequiredAttributeError
    end
  end

  describe 'API integration' do
    context 'when API returns error' do
      it 'handles 404 errors gracefully' do
        stub_request(:get, "#{base_url}/subscriptions/contact/nonexistent")
          .with(headers: { 'Authorization' => "Bearer #{token}" })
          .to_return(status: 404, body: 'Not Found')

        expect { described_class.retrieve('nonexistent') }.to raise_error(Dialpad::APIError, /404 - Not Found/)
      end

      it 'handles 401 errors gracefully' do
        stub_request(:get, "#{base_url}/subscriptions/contact/5923790016724992")
          .with(headers: { 'Authorization' => "Bearer #{token}" })
          .to_return(status: 401, body: 'Unauthorized')

        expect { described_class.retrieve('5923790016724992') }.to raise_error(Dialpad::APIError, /401 - Unauthorized/)
      end
    end
  end
end
