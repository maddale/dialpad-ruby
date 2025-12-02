require 'spec_helper'

RSpec.describe Dialpad::Department do
  let(:base_url) { 'https://api.dialpad.com' }
  let(:token) { 'test_token' }
  let(:client) { Dialpad::Client.new(base_url: base_url, token: token) }

  before do
    allow(Dialpad).to receive(:client).and_return(client)
  end

  describe 'class methods' do
    describe '.retrieve' do
      context 'with valid ID' do
        let(:department_data) do
          {
            'id' => '1234567890123456',
            'name' => 'Sales Department',
            'office_id' => '9876543210987654',
            'auto_call_recording' => false,
            'availability_status' => 'open',
            'country' => 'de',
            'first_action' => 'menu',
            'friday_hours' => ['08:00', '18:00'],
            'group_description' => 'Sales team for North America',
            'hold_queue' => {
              'max_hold_count' => '50',
              'max_hold_seconds' => '900'
            },
            'hours_on' => false,
            'monday_hours' => ['08:00', '18:00'],
            'no_operators_action' => 'bridge_target',
            'phone_numbers' => ['+15551234567'],
            'ring_seconds' => '30',
            'routing_options' => {
              'closed' => {
                'action' => 'voicemail',
                'dtmf' => [
                  {
                    'input' => '0',
                    'options' => {
                      'action' => 'disabled'
                    }
                  },
                  {
                    'input' => '1',
                    'options' => {
                      'action' => 'directory'
                    }
                  }
                ],
                'operator_routing' => 'longestidle',
                'try_dial_operators' => false
              },
              'open' => {
                'action' => 'bridge_target',
                'action_target_id' => '1111222233334444',
                'action_target_type' => 'user',
                'dtmf' => [
                  {
                    'input' => '0',
                    'options' => {
                      'action' => 'operator'
                    }
                  },
                  {
                    'input' => '1',
                    'options' => {
                      'action' => 'directory'
                    }
                  }
                ],
                'operator_routing' => 'longestidle',
                'try_dial_operators' => false
              }
            },
            'saturday_hours' => ['10:00', '14:00'],
            'state' => 'active',
            'sunday_hours' => [],
            'thursday_hours' => ['08:00', '18:00'],
            'timezone' => 'Europe/Berlin',
            'tuesday_hours' => ['08:00', '18:00'],
            'voice_intelligence' => {
              'allow_pause' => true,
              'auto_start' => false
            },
            'wednesday_hours' => ['08:00', '18:00']
          }
        end

        it 'retrieves a department by ID' do
          stub_request(:get, "#{base_url}/departments/123")
            .with(headers: { 'Authorization' => "Bearer #{token}" })
            .to_return(status: 200, body: department_data.to_json, headers: { 'Content-Type' => 'application/json' })

          department = described_class.retrieve('123')

          expect(department).to be_a(described_class)
          expect(department.id).to eq('1234567890123456')
          expect(department.name).to eq('Sales Department')
          expect(department.office_id).to eq('9876543210987654')
          expect(department.auto_call_recording).to be false
          expect(department.availability_status).to eq('open')
          expect(department.country).to eq('de')
          expect(department.first_action).to eq('menu')
          expect(department.group_description).to eq('Sales team for North America')
          expect(department.hold_queue).to be_a(Hash)
          expect(department.hold_queue['max_hold_count']).to eq('50')
          expect(department.hold_queue['max_hold_seconds']).to eq('900')
          expect(department.hours_on).to be false
          expect(department.no_operators_action).to eq('bridge_target')
          expect(department.phone_numbers).to eq(['+15551234567'])
          expect(department.ring_seconds).to eq('30')
          expect(department.state).to eq('active')
          expect(department.timezone).to eq('Europe/Berlin')
          expect(department.voice_intelligence).to be_a(Hash)
          expect(department.voice_intelligence['allow_pause']).to be true
          expect(department.voice_intelligence['auto_start']).to be false
        end
      end

      context 'with invalid ID' do
        it 'raises RequiredAttributeError when ID is nil' do
          expect { described_class.retrieve(nil) }.to raise_error(
            Dialpad::Department::RequiredAttributeError,
            'Missing required attribute: ID'
          )
        end

        it 'raises RequiredAttributeError when ID is empty' do
          expect { described_class.retrieve('') }.to raise_error(
            Dialpad::Department::RequiredAttributeError,
            'Missing required attribute: ID'
          )
        end
      end
    end

    describe '.list' do
      context 'with departments' do
        let(:departments_data) do
          {
            'cursor' => 'dept_cursor_789',
            'items' => [
              {
                'id' => '1234567890123456',
                'name' => 'Sales Department',
                'office_id' => '9876543210987654',
                'auto_call_recording' => false,
                'availability_status' => 'open',
                'country' => 'de',
                'first_action' => 'menu',
                'group_description' => 'Sales team',
                'hold_queue' => {
                  'max_hold_count' => '50',
                  'max_hold_seconds' => '900'
                },
                'hours_on' => false,
                'no_operators_action' => 'bridge_target',
                'phone_numbers' => ['+15551234567'],
                'ring_seconds' => '30',
                'state' => 'active',
                'timezone' => 'Europe/Berlin',
                'voice_intelligence' => {
                  'allow_pause' => true,
                  'auto_start' => false
                }
              },
              {
                'id' => '1234567890123457',
                'name' => 'Support Department',
                'office_id' => '9876543210987654',
                'auto_call_recording' => true,
                'availability_status' => 'closed',
                'country' => 'us',
                'first_action' => 'operator',
                'group_description' => 'Customer support team',
                'hold_queue' => {
                  'max_hold_count' => '25',
                  'max_hold_seconds' => '600'
                },
                'hours_on' => true,
                'no_operators_action' => 'voicemail',
                'phone_numbers' => ['+15559876543'],
                'ring_seconds' => '20',
                'state' => 'inactive',
                'timezone' => 'America/New_York',
                'voice_intelligence' => {
                  'allow_pause' => false,
                  'auto_start' => true
                }
              }
            ]
          }
        end

        it 'returns a PaginatedResponse with departments' do
          stub_request(:get, "#{base_url}/departments")
            .with(headers: { 'Authorization' => "Bearer #{token}" })
            .to_return(status: 200, body: departments_data.to_json, headers: { 'Content-Type' => 'application/json' })

          result = described_class.list

          expect(result).to be_a(Dialpad::PaginatedResponse)
          expect(result.cursor).to eq('dept_cursor_789')
          expect(result.items).to be_an(Array)
          expect(result.items.length).to eq(2)
          expect(result.items.first).to be_a(described_class)
          expect(result.items.first.id).to eq('1234567890123456')
          expect(result.items.first.name).to eq('Sales Department')
          expect(result.items.first.availability_status).to eq('open')
          expect(result.items.last.id).to eq('1234567890123457')
          expect(result.items.last.name).to eq('Support Department')
          expect(result.items.last.availability_status).to eq('closed')
        end

        it 'passes query parameters to API' do
          params = { 'limit' => 10, 'offset' => 0, 'office_id' => '9876543210987654' }
          stub_request(:get, "#{base_url}/departments")
            .with(
              headers: { 'Authorization' => "Bearer #{token}" },
              query: params
            )
            .to_return(status: 200, body: departments_data.to_json, headers: { 'Content-Type' => 'application/json' })

          described_class.list(params)
          # WebMock automatically verifies the request was made with correct params
        end
      end

      context 'with no departments' do
        it 'returns PaginatedResponse with empty items when items is blank' do
          stub_request(:get, "#{base_url}/departments")
            .with(headers: { 'Authorization' => "Bearer #{token}" })
            .to_return(status: 200, body: { 'items' => [] }.to_json, headers: { 'Content-Type' => 'application/json' })

          result = described_class.list

          expect(result).to be_a(Dialpad::PaginatedResponse)
          expect(result.cursor).to be_nil
          expect(result.items).to eq([])
        end

        it 'returns PaginatedResponse with empty items when items is nil' do
          stub_request(:get, "#{base_url}/departments")
            .with(headers: { 'Authorization' => "Bearer #{token}" })
            .to_return(status: 200, body: {}.to_json, headers: { 'Content-Type' => 'application/json' })

          result = described_class.list

          expect(result).to be_a(Dialpad::PaginatedResponse)
          expect(result.cursor).to be_nil
          expect(result.items).to eq([])
        end
      end
    end

    describe '.create' do
      context 'with valid attributes' do
        let(:create_attributes) do
          {
            name: 'New Sales Department',
            office_id: '9876543210987654',
            auto_call_recording: false,
            availability_status: 'open',
            first_action: 'menu',
            ring_seconds: '30'
          }
        end

        let(:created_department_data) do
          {
            'id' => '1234567890123458',
            'name' => 'New Sales Department',
            'office_id' => '9876543210987654',
            'auto_call_recording' => false,
            'availability_status' => 'open',
            'first_action' => 'menu',
            'ring_seconds' => '30',
            'country' => 'de',
            'state' => 'active',
            'timezone' => 'Europe/Berlin',
            'hold_queue' => {
              'max_hold_count' => '50',
              'max_hold_seconds' => '900'
            },
            'voice_intelligence' => {
              'allow_pause' => true,
              'auto_start' => false
            }
          }
        end

        it 'creates a new department' do
          stub_request(:post, "#{base_url}/departments")
            .with(
              headers: { 'Authorization' => "Bearer #{token}" },
              body: create_attributes.to_json
            )
            .to_return(status: 201, body: created_department_data.to_json, headers: { 'Content-Type' => 'application/json' })

          department = described_class.create(create_attributes)

          expect(department).to be_a(described_class)
          expect(department.id).to eq('1234567890123458')
          expect(department.name).to eq('New Sales Department')
          expect(department.office_id).to eq('9876543210987654')
          expect(department.auto_call_recording).to be false
          expect(department.availability_status).to eq('open')
          expect(department.first_action).to eq('menu')
          expect(department.ring_seconds).to eq('30')
        end
      end

      context 'with missing required attributes' do
        it 'raises RequiredAttributeError when name is missing' do
          expect { described_class.create({ office_id: 123 }) }.to raise_error(
            Dialpad::Department::RequiredAttributeError,
            'Missing required attributes: name'
          )
        end

        it 'raises RequiredAttributeError when office_id is missing' do
          expect { described_class.create({ name: 'Test Department' }) }.to raise_error(
            Dialpad::Department::RequiredAttributeError,
            'Missing required attributes: office_id'
          )
        end

        it 'raises RequiredAttributeError when both required attributes are missing' do
          expect { described_class.create({}) }.to raise_error(
            Dialpad::Department::RequiredAttributeError,
            'Missing required attributes: name, office_id'
          )
        end
      end
    end

    describe '.update' do
      context 'with valid ID and attributes' do
        let(:update_attributes) do
          {
            name: 'Updated Sales Department',
            auto_call_recording: true,
            ring_seconds: '45'
          }
        end

        let(:updated_department_data) do
          {
            'id' => '1234567890123456',
            'name' => 'Updated Sales Department',
            'office_id' => '9876543210987654',
            'auto_call_recording' => true,
            'availability_status' => 'open',
            'ring_seconds' => '45',
            'country' => 'de',
            'state' => 'active',
            'timezone' => 'Europe/Berlin',
            'hold_queue' => {
              'max_hold_count' => '50',
              'max_hold_seconds' => '900'
            },
            'voice_intelligence' => {
              'allow_pause' => true,
              'auto_start' => false
            }
          }
        end

        it 'updates a department' do
          stub_request(:patch, "#{base_url}/departments/123")
            .with(
              headers: { 'Authorization' => "Bearer #{token}" },
              body: update_attributes.to_json
            )
            .to_return(status: 200, body: updated_department_data.to_json, headers: { 'Content-Type' => 'application/json' })

          department = described_class.update('123', update_attributes)

          expect(department).to be_a(described_class)
          expect(department.id).to eq('1234567890123456')
          expect(department.name).to eq('Updated Sales Department')
          expect(department.auto_call_recording).to be true
          expect(department.ring_seconds).to eq('45')
        end
      end

      context 'with invalid ID' do
        it 'raises RequiredAttributeError when ID is nil' do
          expect { described_class.update(nil, {}) }.to raise_error(
            Dialpad::Department::RequiredAttributeError,
            'Missing required attribute: ID'
          )
        end

        it 'raises RequiredAttributeError when ID is empty' do
          expect { described_class.update('', {}) }.to raise_error(
            Dialpad::Department::RequiredAttributeError,
            'Missing required attribute: ID'
          )
        end
      end
    end

    describe '.destroy' do
      context 'with valid ID' do
        let(:destroyed_department_data) do
          {
            'id' => '1234567890123456',
            'name' => 'Sales Department',
            'office_id' => '9876543210987654',
            'deleted' => true
          }
        end

        it 'destroys a department' do
          stub_request(:delete, "#{base_url}/departments/123")
            .with(headers: { 'Authorization' => "Bearer #{token}" })
            .to_return(status: 200, body: destroyed_department_data.to_json, headers: { 'Content-Type' => 'application/json' })

          department = described_class.destroy('123')

          expect(department).to be_a(described_class)
          expect(department.id).to eq('1234567890123456')
          expect(department.name).to eq('Sales Department')
        end
      end

      context 'with invalid ID' do
        it 'raises RequiredAttributeError when ID is nil' do
          expect { described_class.destroy(nil) }.to raise_error(
            Dialpad::Department::RequiredAttributeError,
            'Missing required attribute: ID'
          )
        end

        it 'raises RequiredAttributeError when ID is empty' do
          expect { described_class.destroy('') }.to raise_error(
            Dialpad::Department::RequiredAttributeError,
            'Missing required attribute: ID'
          )
        end
      end
    end
  end

  describe 'instance methods' do
    let(:department_attributes) do
      {
        id: '1234567890123456',
        name: 'Sales Department',
        office_id: '9876543210987654',
        auto_call_recording: false,
        availability_status: 'open',
        country: 'de',
        first_action: 'menu',
        friday_hours: ['08:00', '18:00'],
        group_description: 'Sales team for North America',
        hold_queue: {
          'max_hold_count' => '50',
          'max_hold_seconds' => '900'
        },
        hours_on: false,
        monday_hours: ['08:00', '18:00'],
        no_operators_action: 'bridge_target',
        phone_numbers: ['+15551234567'],
        ring_seconds: '30',
        routing_options: {
          'closed' => {
            'action' => 'voicemail',
            'operator_routing' => 'longestidle',
            'try_dial_operators' => false
          },
          'open' => {
            'action' => 'bridge_target',
            'action_target_id' => '1111222233334444',
            'action_target_type' => 'user',
            'operator_routing' => 'longestidle',
            'try_dial_operators' => false
          }
        },
        saturday_hours: ['10:00', '14:00'],
        state: 'active',
        sunday_hours: [],
        thursday_hours: ['08:00', '18:00'],
        timezone: 'Europe/Berlin',
        tuesday_hours: ['08:00', '18:00'],
        voice_intelligence: {
          'allow_pause' => true,
          'auto_start' => false
        },
        wednesday_hours: ['08:00', '18:00']
      }
    end

    let(:department) { described_class.new(department_attributes) }

    describe '#initialize' do
      it 'sets attributes from hash' do
        expect(department.id).to eq('1234567890123456')
        expect(department.name).to eq('Sales Department')
        expect(department.office_id).to eq('9876543210987654')
        expect(department.auto_call_recording).to be false
        expect(department.availability_status).to eq('open')
        expect(department.country).to eq('de')
        expect(department.first_action).to eq('menu')
        expect(department.friday_hours).to eq(['08:00', '18:00'])
        expect(department.group_description).to eq('Sales team for North America')
        expect(department.hold_queue).to be_a(Hash)
        expect(department.hold_queue['max_hold_count']).to eq('50')
        expect(department.hold_queue['max_hold_seconds']).to eq('900')
        expect(department.hours_on).to be false
        expect(department.monday_hours).to eq(['08:00', '18:00'])
        expect(department.no_operators_action).to eq('bridge_target')
        expect(department.phone_numbers).to eq(['+15551234567'])
        expect(department.ring_seconds).to eq('30')
        expect(department.routing_options).to be_a(Hash)
        expect(department.saturday_hours).to eq(['10:00', '14:00'])
        expect(department.state).to eq('active')
        expect(department.sunday_hours).to eq([])
        expect(department.thursday_hours).to eq(['08:00', '18:00'])
        expect(department.timezone).to eq('Europe/Berlin')
        expect(department.tuesday_hours).to eq(['08:00', '18:00'])
        expect(department.voice_intelligence).to be_a(Hash)
        expect(department.voice_intelligence['allow_pause']).to be true
        expect(department.voice_intelligence['auto_start']).to be false
        expect(department.wednesday_hours).to eq(['08:00', '18:00'])
      end

      it 'converts string keys to symbols' do
        department_with_string_keys = described_class.new(
          'id' => '1234567890123456',
          'name' => 'Sales Department',
          'office_id' => '9876543210987654'
        )

        expect(department_with_string_keys.id).to eq('1234567890123456')
        expect(department_with_string_keys.name).to eq('Sales Department')
        expect(department_with_string_keys.office_id).to eq('9876543210987654')
      end

      it 'handles empty attributes' do
        empty_department = described_class.new({})
        expect(empty_department.attributes).to eq({})
      end
    end

    describe '#operator_users' do
      context 'when department has operator users' do
        let(:operators_data) do
          {
            'users' => [
              {
                'id' => '5555666677778888',
                'display_name' => 'John Smith',
                'first_name' => 'John',
                'last_name' => 'Smith',
                'emails' => ['john.smith@example.com'],
                'office_id' => '9876543210987654',
                'is_available' => true,
                'is_online' => true
              },
              {
                'id' => '9999000011112222',
                'display_name' => 'Jane Doe',
                'first_name' => 'Jane',
                'last_name' => 'Doe',
                'emails' => ['jane.doe@example.com'],
                'office_id' => '9876543210987654',
                'is_available' => false,
                'is_online' => true
              }
            ]
          }
        end

        it 'returns an array of User objects' do
          stub_request(:get, "#{base_url}/departments/#{department.id}/operators")
            .with(headers: { 'Authorization' => "Bearer #{token}" })
            .to_return(status: 200, body: operators_data.to_json, headers: { 'Content-Type' => 'application/json' })

          operators = department.operator_users

          expect(operators).to be_an(Array)
          expect(operators.length).to eq(2)
          expect(operators.first).to be_a(Dialpad::User)
          expect(operators.first.id).to eq('5555666677778888')
          expect(operators.first.display_name).to eq('John Smith')
          expect(operators.first.is_available).to be true
          expect(operators.last.id).to eq('9999000011112222')
          expect(operators.last.display_name).to eq('Jane Doe')
          expect(operators.last.is_available).to be false
        end
      end

      context 'when department has no operator users' do
        it 'returns empty array when users is blank' do
          stub_request(:get, "#{base_url}/departments/#{department.id}/operators")
            .with(headers: { 'Authorization' => "Bearer #{token}" })
            .to_return(status: 200, body: { 'users' => [] }.to_json, headers: { 'Content-Type' => 'application/json' })

          operators = department.operator_users

          expect(operators).to eq([])
        end

        it 'returns empty array when users is nil' do
          stub_request(:get, "#{base_url}/departments/#{department.id}/operators")
            .with(headers: { 'Authorization' => "Bearer #{token}" })
            .to_return(status: 200, body: {}.to_json, headers: { 'Content-Type' => 'application/json' })

          operators = department.operator_users

          expect(operators).to eq([])
        end
      end
    end

    describe 'attribute access' do
      it 'allows access to all defined attributes' do
        expect(department).to respond_to(:auto_call_recording)
        expect(department).to respond_to(:availability_status)
        expect(department).to respond_to(:country)
        expect(department).to respond_to(:first_action)
        expect(department).to respond_to(:friday_hours)
        expect(department).to respond_to(:group_description)
        expect(department).to respond_to(:hold_queue)
        expect(department).to respond_to(:hours_on)
        expect(department).to respond_to(:id)
        expect(department).to respond_to(:monday_hours)
        expect(department).to respond_to(:name)
        expect(department).to respond_to(:no_operators_action)
        expect(department).to respond_to(:office_id)
        expect(department).to respond_to(:phone_numbers)
        expect(department).to respond_to(:ring_seconds)
        expect(department).to respond_to(:routing_options)
        expect(department).to respond_to(:saturday_hours)
        expect(department).to respond_to(:state)
        expect(department).to respond_to(:sunday_hours)
        expect(department).to respond_to(:thursday_hours)
        expect(department).to respond_to(:timezone)
        expect(department).to respond_to(:tuesday_hours)
        expect(department).to respond_to(:voice_intelligence)
        expect(department).to respond_to(:wednesday_hours)
      end

      it 'raises NoMethodError for undefined attributes' do
        expect { department.undefined_attribute }.to raise_error(NoMethodError)
      end
    end
  end

  describe 'error handling' do
    it 'defines RequiredAttributeError' do
      expect(Dialpad::Department::RequiredAttributeError).to be < Dialpad::DialpadObject::RequiredAttributeError
    end
  end

  describe 'API integration' do
    context 'when API returns error' do
      it 'handles 404 errors gracefully' do
        stub_request(:get, "#{base_url}/departments/nonexistent")
          .with(headers: { 'Authorization' => "Bearer #{token}" })
          .to_return(status: 404, body: 'Not Found')

        expect { described_class.retrieve('nonexistent') }.to raise_error(Dialpad::APIError, /404 - Not Found/)
      end

      it 'handles 401 errors gracefully' do
        stub_request(:get, "#{base_url}/departments/123")
          .with(headers: { 'Authorization' => "Bearer #{token}" })
          .to_return(status: 401, body: 'Unauthorized')

        expect { described_class.retrieve('123') }.to raise_error(Dialpad::APIError, /401 - Unauthorized/)
      end

      it 'handles 422 errors for create with invalid data' do
        stub_request(:post, "#{base_url}/departments")
          .with(headers: { 'Authorization' => "Bearer #{token}" })
          .to_return(status: 422, body: 'Unprocessable Entity')

        expect { described_class.create({ name: 'Test', office_id: 123 }) }.to raise_error(Dialpad::APIError, /422 - Unprocessable Entity/)
      end
    end
  end
end
