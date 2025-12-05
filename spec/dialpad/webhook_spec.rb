require 'spec_helper'

RSpec.describe Dialpad::Webhook do
  let(:base_url) { 'https://api.dialpad.com' }
  let(:token) { 'test_token' }
  let(:client) { Dialpad::Client.new(base_url: base_url, token: token) }

  before do
    allow(Dialpad).to receive(:client).and_return(client)
  end

  describe 'class methods' do
    describe '.retrieve' do
      context 'with valid ID' do
        let(:webhook_data) do
          {
            'hook_url' => 'https://example.com/webhooks/dialpad/call',
            'id' => '5159136949157888',
            'signature' => {
              'algo' => 'HS256',
              'secret' => 'test_secret',
              'type' => 'jwt'
            }
          }
        end

        it 'retrieves a webhook by ID' do
          stub_request(:get, "#{base_url}/webhooks/5159136949157888")
            .with(headers: { 'Authorization' => "Bearer #{token}" })
            .to_return(status: 200, body: webhook_data.to_json, headers: { 'Content-Type' => 'application/json' })

          webhook = described_class.retrieve('5159136949157888')

          expect(webhook).to be_a(described_class)
          expect(webhook.id).to eq('5159136949157888')
          expect(webhook.hook_url).to eq('https://example.com/webhooks/dialpad/call')
          expect(webhook.signature).to be_a(Hash)
          expect(webhook.signature['algo']).to eq('HS256')
          expect(webhook.signature['secret']).to eq('test_secret')
          expect(webhook.signature['type']).to eq('jwt')
        end
      end

      context 'with invalid ID' do
        it 'raises RequiredAttributeError when ID is nil' do
          expect { described_class.retrieve(nil) }.to raise_error(
            Dialpad::Webhook::RequiredAttributeError,
            'Missing required attribute: ID'
          )
        end

        it 'raises RequiredAttributeError when ID is empty' do
          expect { described_class.retrieve('') }.to raise_error(
            Dialpad::Webhook::RequiredAttributeError,
            'Missing required attribute: ID'
          )
        end
      end
    end

    describe '.list' do
      context 'with webhooks' do
        let(:webhooks_data) do
          {
            'items' => [
              {
                'hook_url' => 'https://example.com/webhooks/dialpad/call',
                'id' => '5159136949157888',
                'signature' => {
                  'algo' => 'HS256',
                  'secret' => 'secret1',
                  'type' => 'jwt'
                }
              },
              {
                'hook_url' => 'https://example.com/webhooks/dialpad/contact',
                'id' => '5159136949157889',
                'signature' => {
                  'algo' => 'HS256',
                  'secret' => 'secret2',
                  'type' => 'jwt'
                }
              }
            ]
          }
        end

        it 'returns a PaginatedResponse with items' do
          stub_request(:get, "#{base_url}/webhooks")
            .with(headers: { 'Authorization' => "Bearer #{token}" })
            .to_return(status: 200, body: webhooks_data.to_json, headers: { 'Content-Type' => 'application/json' })

          webhooks = described_class.list

          expect(webhooks).to be_a(Dialpad::PaginatedResponse)
          expect(webhooks.items.length).to eq(2)
          expect(webhooks.items.first).to be_a(described_class)
          expect(webhooks.items.first.id).to eq('5159136949157888')
          expect(webhooks.items.first.hook_url).to eq('https://example.com/webhooks/dialpad/call')
          expect(webhooks.items.last.id).to eq('5159136949157889')
          expect(webhooks.items.last.hook_url).to eq('https://example.com/webhooks/dialpad/contact')
        end

        it 'passes query parameters to API' do
          params = { 'limit' => 10, 'offset' => 0 }
          stub_request(:get, "#{base_url}/webhooks")
            .with(
              headers: { 'Authorization' => "Bearer #{token}" },
              query: params
            )
            .to_return(status: 200, body: webhooks_data.to_json, headers: { 'Content-Type' => 'application/json' })

          described_class.list(params)
        end
      end

      context 'with no webhooks' do
        it 'returns PaginatedResponse with empty items when items is blank' do
          stub_request(:get, "#{base_url}/webhooks")
            .with(headers: { 'Authorization' => "Bearer #{token}" })
            .to_return(status: 200, body: { 'items' => [] }.to_json, headers: { 'Content-Type' => 'application/json' })

          webhooks = described_class.list

          expect(webhooks).to be_a(Dialpad::PaginatedResponse)
          expect(webhooks.items).to eq([])
        end

        it 'returns PaginatedResponse with empty items when items is nil' do
          stub_request(:get, "#{base_url}/webhooks")
            .with(headers: { 'Authorization' => "Bearer #{token}" })
            .to_return(status: 200, body: {}.to_json, headers: { 'Content-Type' => 'application/json' })

          webhooks = described_class.list

          expect(webhooks).to be_a(Dialpad::PaginatedResponse)
          expect(webhooks.items).to eq([])
        end
      end
    end

    describe '.create' do
      let(:webhook_attributes) do
        {
          hook_url: 'https://example.com/webhooks/dialpad/call'
        }
      end

      let(:created_webhook_data) do
        {
          'hook_url' => 'https://example.com/webhooks/dialpad/call',
          'id' => '5159136949157888',
          'signature' => {
            'algo' => 'HS256',
            'secret' => 'generated_secret',
            'type' => 'jwt'
          }
        }
      end

      context 'with valid attributes' do
        it 'creates a new webhook' do
          stub_request(:post, "#{base_url}/webhooks")
            .with(
              headers: { 'Authorization' => "Bearer #{token}" },
              body: webhook_attributes.to_json
            )
            .to_return(status: 201, body: created_webhook_data.to_json, headers: { 'Content-Type' => 'application/json' })

          webhook = described_class.create(webhook_attributes)

          expect(webhook).to be_a(described_class)
          expect(webhook.id).to eq('5159136949157888')
          expect(webhook.hook_url).to eq('https://example.com/webhooks/dialpad/call')
          expect(webhook.signature).to be_a(Hash)
          expect(webhook.signature['algo']).to eq('HS256')
        end
      end

      context 'with missing required attributes' do
        it 'raises RequiredAttributeError when hook_url is missing' do
          attributes = {}

          expect { described_class.create(attributes) }.to raise_error(
            Dialpad::Webhook::RequiredAttributeError,
            'Missing required attributes: hook_url'
          )
        end

        it 'raises RequiredAttributeError when hook_url is empty' do
          attributes = { hook_url: '' }

          expect { described_class.create(attributes) }.to raise_error(
            Dialpad::Webhook::RequiredAttributeError,
            'Missing required attributes: hook_url'
          )
        end

        it 'raises RequiredAttributeError when hook_url is nil' do
          attributes = { hook_url: nil }

          expect { described_class.create(attributes) }.to raise_error(
            Dialpad::Webhook::RequiredAttributeError,
            'Missing required attributes: hook_url'
          )
        end
      end
    end

    describe '.update' do
      let(:update_attributes) do
        {
          hook_url: 'https://example.com/webhooks/dialpad/updated'
        }
      end

      let(:updated_webhook_data) do
        {
          'hook_url' => 'https://example.com/webhooks/dialpad/updated',
          'id' => '5159136949157888',
          'signature' => {
            'algo' => 'HS256',
            'secret' => 'updated_secret',
            'type' => 'jwt'
          }
        }
      end

      context 'with valid ID and attributes' do
        it 'updates a webhook' do
          stub_request(:patch, "#{base_url}/webhooks/5159136949157888")
            .with(
              headers: { 'Authorization' => "Bearer #{token}" },
              body: update_attributes.to_json
            )
            .to_return(status: 200, body: updated_webhook_data.to_json, headers: { 'Content-Type' => 'application/json' })

          webhook = described_class.update('5159136949157888', update_attributes)

          expect(webhook).to be_a(described_class)
          expect(webhook.id).to eq('5159136949157888')
          expect(webhook.hook_url).to eq('https://example.com/webhooks/dialpad/updated')
          expect(webhook.signature['secret']).to eq('updated_secret')
        end
      end

      context 'with invalid ID' do
        it 'raises RequiredAttributeError when ID is nil' do
          expect { described_class.update(nil, update_attributes) }.to raise_error(
            Dialpad::Webhook::RequiredAttributeError,
            'Missing required attribute: ID'
          )
        end

        it 'raises RequiredAttributeError when ID is empty' do
          expect { described_class.update('', update_attributes) }.to raise_error(
            Dialpad::Webhook::RequiredAttributeError,
            'Missing required attribute: ID'
          )
        end
      end
    end

    describe '.destroy' do
      let(:deleted_webhook_data) do
        {
          'hook_url' => 'https://example.com/webhooks/dialpad/call',
          'id' => '5159136949157888',
          'signature' => {
            'algo' => 'HS256',
            'secret' => 'deleted_secret',
            'type' => 'jwt'
          }
        }
      end

      context 'with valid ID' do
        it 'deletes a webhook' do
          stub_request(:delete, "#{base_url}/webhooks/5159136949157888")
            .with(headers: { 'Authorization' => "Bearer #{token}" })
            .to_return(status: 200, body: deleted_webhook_data.to_json, headers: { 'Content-Type' => 'application/json' })

          webhook = described_class.destroy('5159136949157888')

          expect(webhook).to be_a(described_class)
          expect(webhook.id).to eq('5159136949157888')
          expect(webhook.hook_url).to eq('https://example.com/webhooks/dialpad/call')
        end
      end

      context 'with invalid ID' do
        it 'raises RequiredAttributeError when ID is nil' do
          expect { described_class.destroy(nil) }.to raise_error(
            Dialpad::Webhook::RequiredAttributeError,
            'Missing required attribute: ID'
          )
        end

        it 'raises RequiredAttributeError when ID is empty' do
          expect { described_class.destroy('') }.to raise_error(
            Dialpad::Webhook::RequiredAttributeError,
            'Missing required attribute: ID'
          )
        end
      end
    end
  end

  describe 'instance methods' do
    let(:webhook_attributes) do
      {
        hook_url: 'https://example.com/webhooks/dialpad/call',
        id: '5159136949157888',
        signature: {
          algo: 'HS256',
          secret: 'test_secret',
          type: 'jwt'
        }
      }
    end

    let(:webhook) { described_class.new(webhook_attributes) }

    describe '#initialize' do
      it 'sets attributes from hash' do
        expect(webhook.hook_url).to eq('https://example.com/webhooks/dialpad/call')
        expect(webhook.id).to eq('5159136949157888')
        expect(webhook.signature).to be_a(Hash)
        expect(webhook.signature[:algo]).to eq('HS256')
        expect(webhook.signature[:secret]).to eq('test_secret')
        expect(webhook.signature[:type]).to eq('jwt')
      end

      it 'converts string keys to symbols' do
        webhook_with_string_keys = described_class.new(
          'hook_url' => 'https://example.com/webhooks/dialpad/call',
          'id' => '5159136949157888',
          'signature' => {
            'algo' => 'HS256',
            'secret' => 'test_secret',
            'type' => 'jwt'
          }
        )

        expect(webhook_with_string_keys.hook_url).to eq('https://example.com/webhooks/dialpad/call')
        expect(webhook_with_string_keys.id).to eq('5159136949157888')
        expect(webhook_with_string_keys.signature).to be_a(Hash)
      end

      it 'handles empty attributes' do
        empty_webhook = described_class.new({})
        expect(empty_webhook.attributes).to eq({})
      end
    end

    describe 'attribute access' do
      it 'allows access to all defined attributes' do
        expect(webhook).to respond_to(:hook_url)
        expect(webhook).to respond_to(:id)
        expect(webhook).to respond_to(:signature)
      end

      it 'raises NoMethodError for undefined attributes' do
        expect { webhook.undefined_attribute }.to raise_error(NoMethodError)
      end

      it 'responds to defined attributes' do
        expect(webhook.respond_to?(:hook_url)).to be true
        expect(webhook.respond_to?(:id)).to be true
        expect(webhook.respond_to?(:signature)).to be true
      end

      it 'does not respond to undefined attributes' do
        expect(webhook.respond_to?(:undefined_attribute)).to be false
      end
    end

    describe 'signature handling' do
      let(:webhook_with_signature) do
        described_class.new(
          hook_url: 'https://example.com/webhooks/dialpad/call',
          id: '5159136949157888',
          signature: {
            algo: 'HS256',
            secret: 'my_secret_key',
            type: 'jwt'
          }
        )
      end

      it 'handles signature object' do
        expect(webhook_with_signature.signature).to be_a(Hash)
        expect(webhook_with_signature.signature[:algo]).to eq('HS256')
        expect(webhook_with_signature.signature[:secret]).to eq('my_secret_key')
        expect(webhook_with_signature.signature[:type]).to eq('jwt')
      end

      it 'allows access to signature properties' do
        signature = webhook_with_signature.signature
        expect(signature[:algo]).to eq('HS256')
        expect(signature[:secret]).to eq('my_secret_key')
        expect(signature[:type]).to eq('jwt')
      end
    end
  end

  describe 'error handling' do
    it 'defines RequiredAttributeError' do
      expect(Dialpad::Webhook::RequiredAttributeError).to be < Dialpad::DialpadObject::RequiredAttributeError
    end
  end

  describe 'API integration' do
    context 'when API returns error' do
      it 'handles 404 errors gracefully' do
        stub_request(:get, "#{base_url}/webhooks/nonexistent")
          .with(headers: { 'Authorization' => "Bearer #{token}" })
          .to_return(status: 404, body: 'Not Found')

        expect { described_class.retrieve('nonexistent') }.to raise_error(Dialpad::APIError, /404 - Not Found/)
      end

      it 'handles 401 errors gracefully' do
        stub_request(:get, "#{base_url}/webhooks/5159136949157888")
          .with(headers: { 'Authorization' => "Bearer #{token}" })
          .to_return(status: 401, body: 'Unauthorized')

        expect { described_class.retrieve('5159136949157888') }.to raise_error(Dialpad::APIError, /401 - Unauthorized/)
      end
    end
  end
end
