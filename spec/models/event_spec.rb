require 'rails_helper'

RSpec.describe Event, type: :model do
  it 'one simple test example' do
    Event.create kind: 'opening',
                 starts_at: DateTime.parse('2014-08-04 09:30'),
                 ends_at: DateTime.parse('2014-08-04 12:30'),
                 weekly_recurring: true

    Event.create kind: 'appointment',
                 starts_at: DateTime.parse('2014-08-11 10:30'),
                 ends_at: DateTime.parse('2014-08-11 11:30')

    availabilities = Event.availabilities DateTime.parse('2014-08-10')
    expect(availabilities).to eq []
    # expect(availabilities[0][:date]).to eq Date.new(2014, 8, 10)
    # expect(availabilities[0][:slots]).to eq []
    # expect(availabilities[1][:date]).to eq Date.new(2014, 8, 11)
    # expect(availabilities[1][:slots]). to eq ['9:30', '10:00', '11:30', '12:00']
    # expect(availabilities[2][:slots]).to eq []
    # expect(availabilities[6][:date]).to eq Date.new(2014, 8, 16)
    # expect(availabilities.length).to eq 7
  end
end
