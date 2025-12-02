require 'spec_helper'

RSpec.describe Dialpad::CallCenter do
  let(:base_url) { 'https://api.dialpad.com' }
  let(:token) { 'test_token' }
  let(:client) { Dialpad::Client.new(base_url: base_url, token: token) }

  before do
    allow(Dialpad).to receive(:client).and_return(client)
  end

  describe 'class methods' do
    describe '.retrieve' do
      context 'with valid ID' do
        let(:call_center_data) do
          {
            'advanced_settings' => {
              'auto_call_recording' => {
                'call_recording_inbound' => true,
                'call_recording_outbound' => true
              },
              'max_wrap_up_seconds' => '0'
            },
            'alerts' => {
              'cc_service_level' => '95',
              'cc_service_level_seconds' => '60'
            },
            'availability_status' => 'open',
            'country' => 'us',
            'first_action' => 'menu',
            'friday_hours' => ['08:00', '18:00'],
            'group_description' => 'Customer Service Call Center',
            'hold_queue' => {
              'announce_estimated_wait_time' => true,
              'announce_position' => true,
              'announcement_interval_seconds' => '120',
              'estimated_wait_time_max' => '30',
              'max_hold_count' => '50',
              'max_hold_seconds' => '900',
              'queue_callback_dtmf' => '9',
              'queue_callback_threshold' => '5',
              'queue_escape_dtmf' => '*'
            },
            'hours_on' => false,
            'id' => '1234567890123456',
            'monday_hours' => ['08:00', '18:00'],
            'name' => 'Main Call Center',
            'no_operators_action' => 'bridge_target',
            'office_id' => '9876543210987654',
            'phone_numbers' => ['+15551234567', '+15559876543'],
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
            'state' => 'active',
            'thursday_hours' => ['08:00', '18:00'],
            'timezone' => 'US/Pacific',
            'tuesday_hours' => ['08:00', '18:00'],
            'voice_intelligence' => {
              'allow_pause' => true,
              'auto_start' => true
            },
            'wednesday_hours' => ['08:00', '18:00']
          }
        end

        it 'retrieves a call center by ID' do
          stub_request(:get, "#{base_url}/callcenters/123")
            .with(headers: { 'Authorization' => "Bearer #{token}" })
            .to_return(status: 200, body: call_center_data.to_json, headers: { 'Content-Type' => 'application/json' })

          call_center = described_class.retrieve('123')

          expect(call_center).to be_a(described_class)
          expect(call_center.id).to eq('1234567890123456')
          expect(call_center.name).to eq('Main Call Center')
          expect(call_center.office_id).to eq('9876543210987654')
          expect(call_center.availability_status).to eq('open')
          expect(call_center.country).to eq('us')
          expect(call_center.first_action).to eq('menu')
          expect(call_center.group_description).to eq('Customer Service Call Center')
          expect(call_center.hold_queue).to be_a(Hash)
          expect(call_center.hold_queue['max_hold_count']).to eq('50')
          expect(call_center.hold_queue['max_hold_seconds']).to eq('900')
          expect(call_center.hold_queue['announce_estimated_wait_time']).to be true
          expect(call_center.hours_on).to be false
          expect(call_center.no_operators_action).to eq('bridge_target')
          expect(call_center.phone_numbers).to eq(['+15551234567', '+15559876543'])
          expect(call_center.ring_seconds).to eq('30')
          expect(call_center.state).to eq('active')
          expect(call_center.timezone).to eq('US/Pacific')
          expect(call_center.voice_intelligence).to be_a(Hash)
          expect(call_center.voice_intelligence['allow_pause']).to be true
          expect(call_center.voice_intelligence['auto_start']).to be true
          expect(call_center.advanced_settings).to be_a(Hash)
          expect(call_center.advanced_settings['max_wrap_up_seconds']).to eq('0')
          expect(call_center.alerts).to be_a(Hash)
          expect(call_center.alerts['cc_service_level']).to eq('95')
        end
      end

      context 'with invalid ID' do
        it 'raises RequiredAttributeError when ID is nil' do
          expect { described_class.retrieve(nil) }.to raise_error(
            Dialpad::CallCenter::RequiredAttributeError,
            'Missing required attribute: ID'
          )
        end

        it 'raises RequiredAttributeError when ID is empty' do
          expect { described_class.retrieve('') }.to raise_error(
            Dialpad::CallCenter::RequiredAttributeError,
            'Missing required attribute: ID'
          )
        end
      end
    end

    describe '.list' do
      context 'with call centers' do
        let(:call_centers_data) do
          {
            'cursor' => 'test_cursor_123',
            'items' => [
              {
                'advanced_settings' => {
                  'auto_call_recording' => {
                    'call_recording_inbound' => true,
                    'call_recording_outbound' => true
                  },
                  'max_wrap_up_seconds' => '0'
                },
                'alerts' => {
                  'cc_service_level' => '95',
                  'cc_service_level_seconds' => '60'
                },
                'availability_status' => 'open',
                'country' => 'us',
                'first_action' => 'menu',
                'friday_hours' => ['08:00', '18:00'],
                'group_description' => 'Customer Service Call Center',
                'hold_queue' => {
                  'max_hold_count' => '50',
                  'max_hold_seconds' => '900'
                },
                'hours_on' => false,
                'id' => '1234567890123456',
                'monday_hours' => ['08:00', '18:00'],
                'name' => 'Main Call Center',
                'no_operators_action' => 'bridge_target',
                'office_id' => '9876543210987654',
                'phone_numbers' => ['+15551234567'],
                'ring_seconds' => '30',
                'state' => 'active',
                'timezone' => 'US/Pacific',
                'voice_intelligence' => {
                  'allow_pause' => true,
                  'auto_start' => true
                }
              },
              {
                'advanced_settings' => {
                  'auto_call_recording' => {
                    'call_recording_inbound' => false,
                    'call_recording_outbound' => false
                  },
                  'max_wrap_up_seconds' => '30'
                },
                'alerts' => {
                  'cc_service_level' => '90',
                  'cc_service_level_seconds' => '45'
                },
                'availability_status' => 'closed',
                'country' => 'ca',
                'first_action' => 'operator',
                'friday_hours' => ['09:00', '17:00'],
                'group_description' => 'Support Call Center',
                'hold_queue' => {
                  'max_hold_count' => '25',
                  'max_hold_seconds' => '600'
                },
                'hours_on' => true,
                'id' => '1234567890123457',
                'monday_hours' => ['09:00', '17:00'],
                'name' => 'Support Call Center',
                'no_operators_action' => 'voicemail',
                'office_id' => '9876543210987654',
                'phone_numbers' => ['+15559876543'],
                'ring_seconds' => '20',
                'state' => 'inactive',
                'timezone' => 'America/Toronto',
                'voice_intelligence' => {
                  'allow_pause' => false,
                  'auto_start' => false
                }
              }
            ]
          }
        end

        it 'returns a PaginatedResponse with cursor and items' do
          stub_request(:get, "#{base_url}/callcenters")
            .with(headers: { 'Authorization' => "Bearer #{token}" })
            .to_return(status: 200, body: call_centers_data.to_json, headers: { 'Content-Type' => 'application/json' })

          result = described_class.list

          expect(result).to be_a(Dialpad::PaginatedResponse)
          expect(result.cursor).to eq('test_cursor_123')
          expect(result.items).to be_an(Array)
          expect(result.items.length).to eq(2)
          expect(result.items.first).to be_a(described_class)
          expect(result.items.first.id).to eq('1234567890123456')
          expect(result.items.first.name).to eq('Main Call Center')
          expect(result.items.first.availability_status).to eq('open')
          expect(result.items.last.id).to eq('1234567890123457')
          expect(result.items.last.name).to eq('Support Call Center')
          expect(result.items.last.availability_status).to eq('closed')
        end

        it 'passes query parameters to API' do
          params = { 'limit' => 10, 'offset' => 0, 'office_id' => '9876543210987654' }
          stub_request(:get, "#{base_url}/callcenters")
            .with(
              headers: { 'Authorization' => "Bearer #{token}" },
              query: params
            )
            .to_return(status: 200, body: call_centers_data.to_json, headers: { 'Content-Type' => 'application/json' })

          described_class.list(params)
        end

        it 'returns PaginatedResponse with nil cursor when cursor is nil' do
          call_centers_data_no_cursor = call_centers_data.dup
          call_centers_data_no_cursor.delete('cursor')

          stub_request(:get, "#{base_url}/callcenters")
            .with(headers: { 'Authorization' => "Bearer #{token}" })
            .to_return(status: 200, body: call_centers_data_no_cursor.to_json, headers: { 'Content-Type' => 'application/json' })

          result = described_class.list

          expect(result).to be_a(Dialpad::PaginatedResponse)
          expect(result.cursor).to be_nil
          expect(result.items).to be_an(Array)
          expect(result.items.length).to eq(2)
        end
      end

      context 'with no call centers' do
        it 'returns PaginatedResponse with empty items when items is blank' do
          stub_request(:get, "#{base_url}/callcenters")
            .with(headers: { 'Authorization' => "Bearer #{token}" })
            .to_return(status: 200, body: { 'items' => [] }.to_json, headers: { 'Content-Type' => 'application/json' })

          result = described_class.list

          expect(result).to be_a(Dialpad::PaginatedResponse)
          expect(result.cursor).to be_nil
          expect(result.items).to eq([])
        end

        it 'returns PaginatedResponse with empty items when items is nil' do
          stub_request(:get, "#{base_url}/callcenters")
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
            name: 'New Call Center',
            office_id: '9876543210987654',
            availability_status: 'open',
            first_action: 'menu',
            ring_seconds: '30'
          }
        end

        let(:created_call_center_data) do
          {
            'id' => '1234567890123458',
            'name' => 'New Call Center',
            'office_id' => '9876543210987654',
            'availability_status' => 'open',
            'first_action' => 'menu',
            'ring_seconds' => '30',
            'country' => 'us',
            'state' => 'active',
            'timezone' => 'US/Pacific',
            'hold_queue' => {
              'max_hold_count' => '50',
              'max_hold_seconds' => '900'
            },
            'voice_intelligence' => {
              'allow_pause' => true,
              'auto_start' => false
            },
            'advanced_settings' => {
              'auto_call_recording' => {
                'call_recording_inbound' => false,
                'call_recording_outbound' => false
              },
              'max_wrap_up_seconds' => '0'
            }
          }
        end

        it 'creates a new call center' do
          stub_request(:post, "#{base_url}/callcenters")
            .with(
              headers: { 'Authorization' => "Bearer #{token}" },
              body: create_attributes.to_json
            )
            .to_return(status: 201, body: created_call_center_data.to_json, headers: { 'Content-Type' => 'application/json' })

          call_center = described_class.create(create_attributes)

          expect(call_center).to be_a(described_class)
          expect(call_center.id).to eq('1234567890123458')
          expect(call_center.name).to eq('New Call Center')
          expect(call_center.office_id).to eq('9876543210987654')
          expect(call_center.availability_status).to eq('open')
          expect(call_center.first_action).to eq('menu')
          expect(call_center.ring_seconds).to eq('30')
        end
      end

      context 'with missing required attributes' do
        it 'raises RequiredAttributeError when name is missing' do
          expect { described_class.create({ office_id: 123 }) }.to raise_error(
            Dialpad::CallCenter::RequiredAttributeError,
            'Missing required attributes: name'
          )
        end

        it 'raises RequiredAttributeError when office_id is missing' do
          expect { described_class.create({ name: 'Test Call Center' }) }.to raise_error(
            Dialpad::CallCenter::RequiredAttributeError,
            'Missing required attributes: office_id'
          )
        end

        it 'raises RequiredAttributeError when both required attributes are missing' do
          expect { described_class.create({}) }.to raise_error(
            Dialpad::CallCenter::RequiredAttributeError,
            'Missing required attributes: name, office_id'
          )
        end
      end
    end

    describe '.update' do
      context 'with valid ID and attributes' do
        let(:update_attributes) do
          {
            name: 'Updated Call Center',
            ring_seconds: '45',
            availability_status: 'closed'
          }
        end

        let(:updated_call_center_data) do
          {
            'id' => '1234567890123456',
            'name' => 'Updated Call Center',
            'office_id' => '9876543210987654',
            'availability_status' => 'closed',
            'ring_seconds' => '45',
            'country' => 'us',
            'state' => 'active',
            'timezone' => 'US/Pacific',
            'hold_queue' => {
              'max_hold_count' => '50',
              'max_hold_seconds' => '900'
            },
            'voice_intelligence' => {
              'allow_pause' => true,
              'auto_start' => true
            },
            'advanced_settings' => {
              'auto_call_recording' => {
                'call_recording_inbound' => true,
                'call_recording_outbound' => true
              },
              'max_wrap_up_seconds' => '0'
            }
          }
        end

        it 'updates a call center' do
          stub_request(:patch, "#{base_url}/callcenters/123")
            .with(
              headers: { 'Authorization' => "Bearer #{token}" },
              body: update_attributes.to_json
            )
            .to_return(status: 200, body: updated_call_center_data.to_json, headers: { 'Content-Type' => 'application/json' })

          call_center = described_class.update('123', update_attributes)

          expect(call_center).to be_a(described_class)
          expect(call_center.id).to eq('1234567890123456')
          expect(call_center.name).to eq('Updated Call Center')
          expect(call_center.availability_status).to eq('closed')
          expect(call_center.ring_seconds).to eq('45')
        end
      end

      context 'with invalid ID' do
        it 'raises RequiredAttributeError when ID is nil' do
          expect { described_class.update(nil, {}) }.to raise_error(
            Dialpad::CallCenter::RequiredAttributeError,
            'Missing required attribute: ID'
          )
        end

        it 'raises RequiredAttributeError when ID is empty' do
          expect { described_class.update('', {}) }.to raise_error(
            Dialpad::CallCenter::RequiredAttributeError,
            'Missing required attribute: ID'
          )
        end
      end
    end

    describe '.destroy' do
      context 'with valid ID' do
        let(:destroyed_call_center_data) do
          {
            'id' => '1234567890123456',
            'name' => 'Main Call Center',
            'office_id' => '9876543210987654',
            'deleted' => true
          }
        end

        it 'destroys a call center' do
          stub_request(:delete, "#{base_url}/callcenters/123")
            .with(headers: { 'Authorization' => "Bearer #{token}" })
            .to_return(status: 200, body: destroyed_call_center_data.to_json, headers: { 'Content-Type' => 'application/json' })

          call_center = described_class.destroy('123')

          expect(call_center).to be_a(described_class)
          expect(call_center.id).to eq('1234567890123456')
          expect(call_center.name).to eq('Main Call Center')
        end
      end

      context 'with invalid ID' do
        it 'raises RequiredAttributeError when ID is nil' do
          expect { described_class.destroy(nil) }.to raise_error(
            Dialpad::CallCenter::RequiredAttributeError,
            'Missing required attribute: ID'
          )
        end

        it 'raises RequiredAttributeError when ID is empty' do
          expect { described_class.destroy('') }.to raise_error(
            Dialpad::CallCenter::RequiredAttributeError,
            'Missing required attribute: ID'
          )
        end
      end
    end
  end

  describe 'instance methods' do
    let(:call_center_attributes) do
      {
        advanced_settings: {
          'auto_call_recording' => {
            'call_recording_inbound' => true,
            'call_recording_outbound' => true
          },
          'max_wrap_up_seconds' => '0'
        },
        alerts: {
          'cc_service_level' => '95',
          'cc_service_level_seconds' => '60'
        },
        availability_status: 'open',
        country: 'us',
        first_action: 'menu',
        friday_hours: ['08:00', '18:00'],
        group_description: 'Customer Service Call Center',
        hold_queue: {
          'announce_estimated_wait_time' => true,
          'announce_position' => true,
          'announcement_interval_seconds' => '120',
          'max_hold_count' => '50',
          'max_hold_seconds' => '900'
        },
        hours_on: false,
        id: '1234567890123456',
        monday_hours: ['08:00', '18:00'],
        name: 'Main Call Center',
        no_operators_action: 'bridge_target',
        office_id: '9876543210987654',
        phone_numbers: ['+15551234567', '+15559876543'],
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
        state: 'active',
        thursday_hours: ['08:00', '18:00'],
        timezone: 'US/Pacific',
        tuesday_hours: ['08:00', '18:00'],
        voice_intelligence: {
          'allow_pause' => true,
          'auto_start' => true
        },
        wednesday_hours: ['08:00', '18:00']
      }
    end

    let(:call_center) { described_class.new(call_center_attributes) }

    describe '#initialize' do
      it 'sets attributes from hash' do
        expect(call_center.id).to eq('1234567890123456')
        expect(call_center.name).to eq('Main Call Center')
        expect(call_center.office_id).to eq('9876543210987654')
        expect(call_center.availability_status).to eq('open')
        expect(call_center.country).to eq('us')
        expect(call_center.first_action).to eq('menu')
        expect(call_center.friday_hours).to eq(['08:00', '18:00'])
        expect(call_center.group_description).to eq('Customer Service Call Center')
        expect(call_center.hold_queue).to be_a(Hash)
        expect(call_center.hold_queue['max_hold_count']).to eq('50')
        expect(call_center.hold_queue['max_hold_seconds']).to eq('900')
        expect(call_center.hold_queue['announce_estimated_wait_time']).to be true
        expect(call_center.hours_on).to be false
        expect(call_center.monday_hours).to eq(['08:00', '18:00'])
        expect(call_center.no_operators_action).to eq('bridge_target')
        expect(call_center.phone_numbers).to eq(['+15551234567', '+15559876543'])
        expect(call_center.ring_seconds).to eq('30')
        expect(call_center.routing_options).to be_a(Hash)
        expect(call_center.state).to eq('active')
        expect(call_center.thursday_hours).to eq(['08:00', '18:00'])
        expect(call_center.timezone).to eq('US/Pacific')
        expect(call_center.tuesday_hours).to eq(['08:00', '18:00'])
        expect(call_center.voice_intelligence).to be_a(Hash)
        expect(call_center.voice_intelligence['allow_pause']).to be true
        expect(call_center.voice_intelligence['auto_start']).to be true
        expect(call_center.wednesday_hours).to eq(['08:00', '18:00'])
        expect(call_center.advanced_settings).to be_a(Hash)
        expect(call_center.advanced_settings['max_wrap_up_seconds']).to eq('0')
        expect(call_center.alerts).to be_a(Hash)
        expect(call_center.alerts['cc_service_level']).to eq('95')
      end

      it 'converts string keys to symbols' do
        call_center_with_string_keys = described_class.new(
          'id' => '1234567890123456',
          'name' => 'Main Call Center',
          'office_id' => '9876543210987654'
        )

        expect(call_center_with_string_keys.id).to eq('1234567890123456')
        expect(call_center_with_string_keys.name).to eq('Main Call Center')
        expect(call_center_with_string_keys.office_id).to eq('9876543210987654')
      end

      it 'handles empty attributes' do
        empty_call_center = described_class.new({})
        expect(empty_call_center.attributes).to eq({})
      end
    end

    describe 'attribute access' do
      it 'allows access to all defined attributes' do
        expect(call_center).to respond_to(:advanced_settings)
        expect(call_center).to respond_to(:alerts)
        expect(call_center).to respond_to(:availability_status)
        expect(call_center).to respond_to(:country)
        expect(call_center).to respond_to(:first_action)
        expect(call_center).to respond_to(:friday_hours)
        expect(call_center).to respond_to(:group_description)
        expect(call_center).to respond_to(:hold_queue)
        expect(call_center).to respond_to(:hours_on)
        expect(call_center).to respond_to(:id)
        expect(call_center).to respond_to(:monday_hours)
        expect(call_center).to respond_to(:name)
        expect(call_center).to respond_to(:no_operators_action)
        expect(call_center).to respond_to(:office_id)
        expect(call_center).to respond_to(:phone_numbers)
        expect(call_center).to respond_to(:ring_seconds)
        expect(call_center).to respond_to(:routing_options)
        expect(call_center).to respond_to(:state)
        expect(call_center).to respond_to(:thursday_hours)
        expect(call_center).to respond_to(:timezone)
        expect(call_center).to respond_to(:tuesday_hours)
        expect(call_center).to respond_to(:voice_intelligence)
        expect(call_center).to respond_to(:wednesday_hours)
      end

      it 'raises NoMethodError for undefined attributes' do
        expect { call_center.undefined_attribute }.to raise_error(NoMethodError)
      end
    end
  end

  describe 'error handling' do
    it 'defines RequiredAttributeError' do
      expect(Dialpad::CallCenter::RequiredAttributeError).to be < Dialpad::DialpadObject::RequiredAttributeError
    end
  end

  describe 'API integration' do
    context 'when API returns error' do
      it 'handles 404 errors gracefully' do
        stub_request(:get, "#{base_url}/callcenters/nonexistent")
          .with(headers: { 'Authorization' => "Bearer #{token}" })
          .to_return(status: 404, body: 'Not Found')

        expect { described_class.retrieve('nonexistent') }.to raise_error(Dialpad::APIError, /404 - Not Found/)
      end

      it 'handles 401 errors gracefully' do
        stub_request(:get, "#{base_url}/callcenters/123")
          .with(headers: { 'Authorization' => "Bearer #{token}" })
          .to_return(status: 401, body: 'Unauthorized')

        expect { described_class.retrieve('123') }.to raise_error(Dialpad::APIError, /401 - Unauthorized/)
      end

      it 'handles 422 errors for create with invalid data' do
        stub_request(:post, "#{base_url}/callcenters")
          .with(headers: { 'Authorization' => "Bearer #{token}" })
          .to_return(status: 422, body: 'Unprocessable Entity')

        expect { described_class.create({ name: 'Test', office_id: 123 }) }.to raise_error(Dialpad::APIError, /422 - Unprocessable Entity/)
      end
    end
  end
end
