require 'spec_helper'

RSpec.describe Dialpad::Contact do
  let(:base_url) { 'https://api.dialpad.com' }
  let(:token) { 'test_token' }
  let(:client) { Dialpad::Client.new(base_url: base_url, token: token) }

  before do
    allow(Dialpad).to receive(:client).and_return(client)
  end

  describe 'class methods' do
    describe '.retrieve' do
      context 'with valid ID' do
        let(:contact_data) do
          {
            'id' => '123',
            'first_name' => 'John',
            'last_name' => 'Doe',
            'display_name' => 'John Doe',
            'emails' => ['john@example.com'],
            'phones' => ['+1234567890']
          }
        end

        it 'retrieves a contact by ID' do
          stub_request(:get, "#{base_url}/contacts/123")
            .with(headers: { 'Authorization' => "Bearer #{token}" })
            .to_return(status: 200, body: contact_data.to_json, headers: { 'Content-Type' => 'application/json' })

          contact = described_class.retrieve('123')

          expect(contact).to be_a(described_class)
          expect(contact.id).to eq('123')
          expect(contact.first_name).to eq('John')
          expect(contact.last_name).to eq('Doe')
        end
      end

      context 'with invalid ID' do
        it 'raises RequiredAttributeError when ID is nil' do
          expect { described_class.retrieve(nil) }.to raise_error(
            Dialpad::Contact::RequiredAttributeError,
            'Missing required attribute: ID'
          )
        end

        it 'raises RequiredAttributeError when ID is empty' do
          expect { described_class.retrieve('') }.to raise_error(
            Dialpad::Contact::RequiredAttributeError,
            'Missing required attribute: ID'
          )
        end
      end
    end

    describe '.list' do
      context 'with contacts' do
        let(:contacts_data) do
          {
            'items' => [
              {
                'id' => '123',
                'first_name' => 'John',
                'last_name' => 'Doe'
              },
              {
                'id' => '456',
                'first_name' => 'Jane',
                'last_name' => 'Smith'
              }
            ]
          }
        end

        it 'returns a PaginatedResponse with items' do
          stub_request(:get, "#{base_url}/contacts")
            .with(headers: { 'Authorization' => "Bearer #{token}" })
            .to_return(status: 200, body: contacts_data.to_json, headers: { 'Content-Type' => 'application/json' })

          contacts = described_class.list

          expect(contacts).to be_a(Dialpad::PaginatedResponse)
          expect(contacts.items.length).to eq(2)
          expect(contacts.items.first).to be_a(described_class)
          expect(contacts.items.first.id).to eq('123')
          expect(contacts.items.first.first_name).to eq('John')
        end

        it 'passes query parameters' do
          params = { 'limit' => 10, 'offset' => 0 }
          stub_request(:get, "#{base_url}/contacts")
            .with(
              headers: { 'Authorization' => "Bearer #{token}" },
              query: params
            )
            .to_return(status: 200, body: contacts_data.to_json, headers: { 'Content-Type' => 'application/json' })

          described_class.list(params)
        end
      end

      context 'with no contacts' do
        it 'returns PaginatedResponse with empty items when items is blank' do
          stub_request(:get, "#{base_url}/contacts")
            .with(headers: { 'Authorization' => "Bearer #{token}" })
            .to_return(status: 200, body: { 'items' => [] }.to_json, headers: { 'Content-Type' => 'application/json' })

          contacts = described_class.list

          expect(contacts).to be_a(Dialpad::PaginatedResponse)
          expect(contacts.items).to eq([])
        end

        it 'returns PaginatedResponse with empty items when items is nil' do
          stub_request(:get, "#{base_url}/contacts")
            .with(headers: { 'Authorization' => "Bearer #{token}" })
            .to_return(status: 200, body: {}.to_json, headers: { 'Content-Type' => 'application/json' })

          contacts = described_class.list

          expect(contacts).to be_a(Dialpad::PaginatedResponse)
          expect(contacts.items).to eq([])
        end
      end
    end

    describe '.create' do
      let(:contact_attributes) do
        {
          first_name: 'John',
          last_name: 'Doe',
          emails: ['john@example.com'],
          phones: ['+1234567890']
        }
      end

      let(:created_contact_data) do
        {
          'id' => '123',
          'first_name' => 'John',
          'last_name' => 'Doe',
          'emails' => ['john@example.com'],
          'phones' => ['+1234567890']
        }
      end

      context 'with valid attributes' do
        it 'creates a new contact' do
          stub_request(:post, "#{base_url}/contacts")
            .with(
              headers: { 'Authorization' => "Bearer #{token}" },
              body: contact_attributes.to_json
            )
            .to_return(status: 201, body: created_contact_data.to_json, headers: { 'Content-Type' => 'application/json' })

          contact = described_class.create(contact_attributes)

          expect(contact).to be_a(described_class)
          expect(contact.id).to eq('123')
          expect(contact.first_name).to eq('John')
          expect(contact.last_name).to eq('Doe')
        end
      end

      context 'with missing required attributes' do
        it 'raises RequiredAttributeError when first_name is missing' do
          attributes = { last_name: 'Doe' }

          expect { described_class.create(attributes) }.to raise_error(
            Dialpad::Contact::RequiredAttributeError,
            'Missing required attributes: first_name'
          )
        end

        it 'raises RequiredAttributeError when last_name is missing' do
          attributes = { first_name: 'John' }

          expect { described_class.create(attributes) }.to raise_error(
            Dialpad::Contact::RequiredAttributeError,
            'Missing required attributes: last_name'
          )
        end

        it 'raises RequiredAttributeError when both first_name and last_name are missing' do
          attributes = { emails: ['john@example.com'] }

          expect { described_class.create(attributes) }.to raise_error(
            Dialpad::Contact::RequiredAttributeError,
            'Missing required attributes: first_name, last_name'
          )
        end

        it 'raises RequiredAttributeError when first_name is empty' do
          attributes = { first_name: '', last_name: 'Doe' }

          expect { described_class.create(attributes) }.to raise_error(
            Dialpad::Contact::RequiredAttributeError,
            'Missing required attributes: first_name'
          )
        end

        it 'raises RequiredAttributeError when last_name is nil' do
          attributes = { first_name: 'John', last_name: nil }

          expect { described_class.create(attributes) }.to raise_error(
            Dialpad::Contact::RequiredAttributeError,
            'Missing required attributes: last_name'
          )
        end
      end
    end

    describe '.create_or_update' do
      let(:contact_attributes) do
        {
          first_name: 'John',
          last_name: 'Doe',
          uid: 'john.doe@company.com',
          emails: ['john@example.com']
        }
      end

      let(:updated_contact_data) do
        {
          'id' => '123',
          'first_name' => 'John',
          'last_name' => 'Doe',
          'emails' => ['john@example.com']
        }
      end

      context 'with valid attributes' do
        it 'creates or updates a contact' do
          stub_request(:put, "#{base_url}/contacts")
            .with(
              headers: { 'Authorization' => "Bearer #{token}" },
              body: contact_attributes.to_json
            )
            .to_return(status: 200, body: updated_contact_data.to_json, headers: { 'Content-Type' => 'application/json' })

          contact = described_class.create_or_update(contact_attributes)

          expect(contact).to be_a(described_class)
          expect(contact.id).to eq('123')
          expect(contact.first_name).to eq('John')
          expect(contact.last_name).to eq('Doe')
        end
      end

      context 'with missing required attributes' do
        it 'raises RequiredAttributeError when uid is missing' do
          attributes = { first_name: 'John', last_name: 'Doe' }

          expect { described_class.create_or_update(attributes) }.to raise_error(
            Dialpad::Contact::RequiredAttributeError,
            'Missing required attributes: uid'
          )
        end

        it 'raises RequiredAttributeError when all required attributes are missing' do
          attributes = { emails: ['john@example.com'] }

          expect { described_class.create_or_update(attributes) }.to raise_error(
            Dialpad::Contact::RequiredAttributeError,
            'Missing required attributes: first_name, last_name, uid'
          )
        end
      end
    end

    describe '.update' do
      let(:update_attributes) do
        {
          first_name: 'Johnny',
          emails: ['johnny@example.com']
        }
      end

      let(:updated_contact_data) do
        {
          'id' => '123',
          'first_name' => 'Johnny',
          'last_name' => 'Doe',
          'emails' => ['johnny@example.com']
        }
      end

      context 'with valid ID and attributes' do
        it 'updates a contact' do
          stub_request(:patch, "#{base_url}/contacts/123")
            .with(
              headers: { 'Authorization' => "Bearer #{token}" },
              body: update_attributes.to_json
            )
            .to_return(status: 200, body: updated_contact_data.to_json, headers: { 'Content-Type' => 'application/json' })

          contact = described_class.update('123', update_attributes)

          expect(contact).to be_a(described_class)
          expect(contact.id).to eq('123')
          expect(contact.first_name).to eq('Johnny')
          expect(contact.emails).to eq(['johnny@example.com'])
        end
      end

      context 'with invalid ID' do
        it 'raises RequiredAttributeError when ID is nil' do
          expect { described_class.update(nil, update_attributes) }.to raise_error(
            Dialpad::Contact::RequiredAttributeError,
            'Missing required attribute: ID'
          )
        end

        it 'raises RequiredAttributeError when ID is empty' do
          expect { described_class.update('', update_attributes) }.to raise_error(
            Dialpad::Contact::RequiredAttributeError,
            'Missing required attribute: ID'
          )
        end
      end
    end

    describe '.destroy' do
      let(:deleted_contact_data) do
        {
          'id' => '123',
          'first_name' => 'John',
          'last_name' => 'Doe'
        }
      end

      context 'with valid ID' do
        it 'deletes a contact' do
          stub_request(:delete, "#{base_url}/contacts/123")
            .with(headers: { 'Authorization' => "Bearer #{token}" })
            .to_return(status: 200, body: deleted_contact_data.to_json, headers: { 'Content-Type' => 'application/json' })

          contact = described_class.destroy('123')

          expect(contact).to be_a(described_class)
          expect(contact.id).to eq('123')
        end
      end

      context 'with invalid ID' do
        it 'raises RequiredAttributeError when ID is nil' do
          expect { described_class.destroy(nil) }.to raise_error(
            Dialpad::Contact::RequiredAttributeError,
            'Missing required attribute: ID'
          )
        end

        it 'raises RequiredAttributeError when ID is empty' do
          expect { described_class.destroy('') }.to raise_error(
            Dialpad::Contact::RequiredAttributeError,
            'Missing required attribute: ID'
          )
        end
      end
    end
  end

  describe 'instance methods' do
    let(:contact_attributes) do
      {
        id: '123',
        first_name: 'John',
        last_name: 'Doe',
        display_name: 'John Doe',
        emails: ['john@example.com'],
        phones: ['+1234567890'],
        company_name: 'Acme Corp',
        job_title: 'Developer'
      }
    end

    let(:contact) { described_class.new(contact_attributes) }

    describe '#initialize' do
      it 'sets attributes from hash' do
        expect(contact.id).to eq('123')
        expect(contact.first_name).to eq('John')
        expect(contact.last_name).to eq('Doe')
        expect(contact.display_name).to eq('John Doe')
        expect(contact.emails).to eq(['john@example.com'])
        expect(contact.phones).to eq(['+1234567890'])
        expect(contact.company_name).to eq('Acme Corp')
        expect(contact.job_title).to eq('Developer')
      end

      it 'converts string keys to symbols' do
        contact_with_string_keys = described_class.new(
          'id' => '123',
          'first_name' => 'John'
        )

        expect(contact_with_string_keys.id).to eq('123')
        expect(contact_with_string_keys.first_name).to eq('John')
      end

      it 'handles empty attributes' do
        empty_contact = described_class.new({})
        expect(empty_contact.attributes).to eq({})
      end
    end

    describe 'attribute access' do
      it 'allows access to all defined attributes' do
        expect(contact).to respond_to(:id)
        expect(contact).to respond_to(:first_name)
        expect(contact).to respond_to(:last_name)
        expect(contact).to respond_to(:display_name)
        expect(contact).to respond_to(:emails)
        expect(contact).to respond_to(:phones)
        expect(contact).to respond_to(:company_name)
        expect(contact).to respond_to(:job_title)
      end

      it 'raises NoMethodError for undefined attributes' do
        expect { contact.undefined_attribute }.to raise_error(NoMethodError)
      end

      it 'responds to defined attributes' do
        expect(contact.respond_to?(:first_name)).to be true
        expect(contact.respond_to?(:last_name)).to be true
        expect(contact.respond_to?(:id)).to be true
      end

      it 'does not respond to undefined attributes' do
        expect(contact.respond_to?(:undefined_attribute)).to be false
      end
    end
  end

  describe 'error handling' do
    it 'defines RequiredAttributeError' do
      expect(Dialpad::Contact::RequiredAttributeError).to be < Dialpad::DialpadObject::RequiredAttributeError
    end
  end
end
