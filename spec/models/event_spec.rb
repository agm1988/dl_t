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
    expect(availabilities[0][:date]).to eq Date.new(2014, 8, 10)
    expect(availabilities[0][:slots]).to eq []
    expect(availabilities[1][:date]).to eq Date.new(2014, 8, 11)
    expect(availabilities[1][:slots]). to eq %w(9:30 10:00 11:30 12:00)
    expect(availabilities[2][:slots]).to eq []
    expect(availabilities[6][:date]).to eq Date.new(2014, 8, 16)
    expect(availabilities.length).to eq 7
  end

  it 'returns one timeslot if the opening lasts 30 minutes' do
    Event.create kind: 'opening',
                 starts_at: DateTime.parse('2014-08-10 09:30'),
                 ends_at: DateTime.parse('2014-08-10 10:00'),
                 weekly_recurring: false

    availabilities = Event.availabilities DateTime.parse('2014-08-10')
    expect(availabilities[0][:date]).to eq Date.new(2014, 8, 10)
    expect(availabilities[0][:slots]).to eq ['9:30']
  end

  it 'returns date with its openings timeslots' do
    Event.create kind: 'opening',
                 starts_at: DateTime.parse('2014-08-10 09:30'),
                 ends_at: DateTime.parse('2014-08-10 11:00'),
                 weekly_recurring: false

    availabilities = Event.availabilities DateTime.parse('2014-08-10')
    expect(availabilities[0][:date]).to eq Date.new(2014, 8, 10)
    expect(availabilities[0][:slots]).to eq ['9:30', '10:00', '10:30']
  end

  it 'returns array of multiple dates with their openings timeslots' do
    Event.create kind: 'opening',
                 starts_at: DateTime.parse('2014-08-10 09:30'),
                 ends_at: DateTime.parse('2014-08-10 11:00'),
                 weekly_recurring: false

    Event.create kind: 'opening',
                 starts_at: DateTime.parse('2014-08-11 12:30'),
                 ends_at: DateTime.parse('2014-08-11 13:30'),
                 weekly_recurring: false

    availabilities = Event.availabilities DateTime.parse('2014-08-10')
    expect(availabilities[0][:date]).to eq Date.new(2014, 8, 10)
    expect(availabilities[0][:slots]).to eq ['9:30', '10:00', '10:30']
    expect(availabilities[1][:date]).to eq Date.new(2014, 8, 11)
    expect(availabilities[1][:slots]).to eq ['12:30', '13:00']
  end

  it 'returns dates ordered' do
    Event.create kind: 'opening',
                 starts_at: DateTime.parse('2014-08-10 12:30'),
                 ends_at: DateTime.parse('2014-08-10 13:30'),
                 weekly_recurring: false

    Event.create kind: 'opening',
                 starts_at: DateTime.parse('2014-08-10 09:30'),
                 ends_at: DateTime.parse('2014-08-10 11:00'),
                 weekly_recurring: false

    availabilities = Event.availabilities DateTime.parse('2014-08-10')
    expect(availabilities[0][:date]).to eq Date.new(2014, 8, 10)
    expect(availabilities[0][:slots]).to eq ['9:30', '10:00', '10:30', '12:30', '13:00']
  end

  it 'returns recurring openings for the actual date and the next weeks' do
    Event.create kind: 'opening',
                 starts_at: DateTime.parse('2014-08-04 10:30'),
                 ends_at: DateTime.parse('2014-08-04 12:00'),
                 weekly_recurring: true

    Event.create kind: 'opening',
                 starts_at: DateTime.parse('2014-08-10 10:00'),
                 ends_at: DateTime.parse('2014-08-10 11:30'),
                 weekly_recurring: true

    Event.create kind: 'opening',
                 starts_at: DateTime.parse('2014-08-16 09:30'),
                 ends_at: DateTime.parse('2014-08-16 11:00'),
                 weekly_recurring: true

    availabilities = Event.availabilities DateTime.parse('2014-08-16')
    expect(availabilities[0][:date]).to eq Date.new(2014, 8, 16)
    expect(availabilities[0][:slots]).to eq ['9:30', '10:00', '10:30']
    expect(availabilities[1][:date]).to eq Date.new(2014, 8, 17)
    expect(availabilities[1][:slots]).to eq ['10:00', '10:30', '11:00']
    expect(availabilities[2][:date]).to eq Date.new(2014, 8, 18)
    expect(availabilities[2][:slots]).to eq ['10:30', '11:00', '11:30']
  end

  it 'returns timeslots ordered within dates' do
    Event.create kind: 'opening',
                 starts_at: DateTime.parse('2014-08-11 10:30'),
                 ends_at: DateTime.parse('2014-08-11 12:00'),
                 weekly_recurring: false

    Event.create kind: 'opening',
                 starts_at: DateTime.parse('2014-08-12 10:00'),
                 ends_at: DateTime.parse('2014-08-12 11:30'),
                 weekly_recurring: false

    Event.create kind: 'opening',
                 starts_at: DateTime.parse('2014-08-10 09:30'),
                 ends_at: DateTime.parse('2014-08-10 11:00'),
                 weekly_recurring: false

    availabilities = Event.availabilities DateTime.parse('2014-08-10')
    expect(availabilities[0][:date]).to eq Date.new(2014, 8, 10)
    expect(availabilities[1][:date]).to eq Date.new(2014, 8, 11)
    expect(availabilities[2][:date]).to eq Date.new(2014, 8, 12)
  end

  it 'keeps order of timeslots of different openings for the same date' do
    Event.create kind: 'opening',
                 starts_at: DateTime.parse('2014-08-10 12:30'),
                 ends_at: DateTime.parse('2014-08-10 13:30'),
                 weekly_recurring: false

    Event.create kind: 'opening',
                 starts_at: DateTime.parse('2014-08-10 15:00'),
                 ends_at: DateTime.parse('2014-08-10 16:00'),
                 weekly_recurring: false

    Event.create kind: 'opening',
                 starts_at: DateTime.parse('2014-08-10 09:30'),
                 ends_at: DateTime.parse('2014-08-10 11:00'),
                 weekly_recurring: false

    availabilities = Event.availabilities DateTime.parse('2014-08-10')
    slots = ['9:30', '10:00', '10:30', '12:30', '13:00', '15:00', '15:30']
    expect(availabilities[0][:slots]).to eq slots
  end

  it 'returns timeslots starting with 00:00' do
    Event.create kind: 'opening',
                 starts_at: DateTime.parse('2014-08-10 00:00'),
                 ends_at: DateTime.parse('2014-08-10 01:30'),
                 weekly_recurring: false

    availabilities = Event.availabilities DateTime.parse('2014-08-10')
    expect(availabilities[0][:slots]).to eq ['0:00', '0:30', '1:00']
  end

  it 'returns timeslots up to 23:30' do
    Event.create kind: 'opening',
                 starts_at: DateTime.parse('2014-08-10 22:30'),
                 ends_at: DateTime.parse('2014-08-10 24:00'),
                 weekly_recurring: false

    availabilities = Event.availabilities DateTime.parse('2014-08-10')
    expect(availabilities[0][:slots]).to eq ['22:30', '23:00', '23:30']
  end

  it 'returns date with adjacent timeslots of different openings' do
    Event.create kind: 'opening',
                 starts_at: DateTime.parse('2014-08-10 13:30'),
                 ends_at: DateTime.parse('2014-08-10 15:00'),
                 weekly_recurring: false

    Event.create kind: 'opening',
                 starts_at: DateTime.parse('2014-08-10 12:30'),
                 ends_at: DateTime.parse('2014-08-10 13:30'),
                 weekly_recurring: false

    availabilities = Event.availabilities DateTime.parse('2014-08-10')
    slots = ['12:30', '13:00', '13:30', '14:00', '14:30']
    expect(availabilities[0][:slots]).to eq slots
  end

  it 'does not return opening timeslots when they are booked' do
    Event.create kind: 'opening',
                 starts_at: DateTime.parse('2014-08-10 12:30'),
                 ends_at: DateTime.parse('2014-08-10 14:00'),
                 weekly_recurring: false

    Event.create kind: 'appointment',
                 starts_at: DateTime.parse('2014-08-10 12:30'),
                 ends_at: DateTime.parse('2014-08-10 13:30')

    availabilities = Event.availabilities DateTime.parse('2014-08-10')
    expect(availabilities[0][:slots]).to eq ['13:30']
  end

  it "does not return any timeslots of the opening "\
     "that was booked completely" do
    Event.create kind: 'opening',
                 starts_at: DateTime.parse('2014-08-10 12:30'),
                 ends_at: DateTime.parse('2014-08-10 13:30'),
                 weekly_recurring: false

    Event.create kind: 'appointment',
                 starts_at: DateTime.parse('2014-08-10 12:30'),
                 ends_at: DateTime.parse('2014-08-10 13:30')

    availabilities = Event.availabilities DateTime.parse('2014-08-10')
    expect(availabilities[0][:slots]).to eq []
  end

  it "does not return adjacent timeslots from different openings "\
     "booked with the same appointment" do
    Event.create kind: 'opening',
                 starts_at: DateTime.parse('2014-08-10 11:30'),
                 ends_at: DateTime.parse('2014-08-10 12:30'),
                 weekly_recurring: false

    Event.create kind: 'opening',
                 starts_at: DateTime.parse('2014-08-10 12:30'),
                 ends_at: DateTime.parse('2014-08-10 13:30'),
                 weekly_recurring: false

    Event.create kind: 'appointment',
                 starts_at: DateTime.parse('2014-08-10 12:00'),
                 ends_at: DateTime.parse('2014-08-10 13:00')

    availabilities = Event.availabilities DateTime.parse('2014-08-10')
    expect(availabilities[0][:slots]).to eq ['11:30', '13:00']
  end

  it "does not return opening timeslots when they are booked"\
     "with different appointments" do
    Event.create kind: 'opening',
                 starts_at: DateTime.parse('2014-08-10 11:30'),
                 ends_at: DateTime.parse('2014-08-10 15:30'),
                 weekly_recurring: false

    Event.create kind: 'appointment',
                 starts_at: DateTime.parse('2014-08-10 12:00'),
                 ends_at: DateTime.parse('2014-08-10 13:30')

    Event.create kind: 'appointment',
                 starts_at: DateTime.parse('2014-08-10 14:00'),
                 ends_at: DateTime.parse('2014-08-10 15:00')

    availabilities = Event.availabilities DateTime.parse('2014-08-10')
    expect(availabilities[0][:slots]).to eq ['11:30', '13:30', '15:00']
  end

  # To bring more consistency to the algorithm I had to make some assumptions:
  #
  # 1. There should not be openings for the same date with overlapping
  #    or intentionally duplicate timeslots. For example overlapping
  #    appointments from different doctors are supposed to be handled using
  #    associations. If there is one, it will be ignored.
  # 2. There should not be overlapping or duplicate appointments. Such cases
  #    are supposed to be handled with validations. Will be ignored too.
  # 3. There should not be openings that start with one day and ends with the
  #    next one. This is supposed to be properly handled by UI and validations.
  #    If there is an opening with starts_at, its timeslots will be counted
  #    up to 24:00 of the same day
  # 4. All the openings and appointments are supposed to have their times
  #    as a multiples of 30 minutes e.g. 00:00, 00:30, 01:00 ...
  # 5. Openings and appointments should not embrace less than one timeslot
  #    (30 minutes) e.g. starts_at = 14:00, ends_at = 14:00
  #
  # For now I decided not to waste time on implementing validations and other
  # stuff to handle the problems above because I believe it's not related to
  # the task directly. Rather than that I'm going to document the algorithm
  # with the specs for those restrictions.

  it 'counts duplicate timeslots twice' do
    Event.create kind: 'opening',
                 starts_at: DateTime.parse('2014-08-10 09:30'),
                 ends_at: DateTime.parse('2014-08-10 11:00'),
                 weekly_recurring: false

    Event
      .new(kind: 'opening',
           starts_at: DateTime.parse('2014-08-10 09:30'),
           ends_at: DateTime.parse('2014-08-10 11:00'),
           weekly_recurring: false)
      .save(validate: false)

    availabilities = Event.availabilities DateTime.parse('2014-08-10')
    expect(Event.count).to eq 2
    expect(availabilities[0][:date]).to eq Date.new(2014, 8, 10)
    expect(availabilities[0][:slots]).to eq ['9:30', '10:00', '10:30']
  end

  it "returns the correct sets of opening timeslots "\
     "when there are overlapping appointments" do
    Event.create kind: 'opening',
                 starts_at: DateTime.parse('2014-08-10 09:30'),
                 ends_at: DateTime.parse('2014-08-10 11:00'),
                 weekly_recurring: false

    Event.create kind: 'opening',
                 starts_at: DateTime.parse('2014-08-10 10:00'),
                 ends_at: DateTime.parse('2014-08-10 11:30'),
                 weekly_recurring: false

    availabilities = Event.availabilities DateTime.parse('2014-08-10')
    expect(availabilities[0][:slots]).to eq ['9:30', '10:00', '10:30', '11:00']
  end

  it "does not count timeslots after 24:00 of the opening "\
     "which has ends_at with the next day" do
    Event.create kind: 'opening',
                 starts_at: DateTime.parse('2014-08-10 23:00'),
                 ends_at: DateTime.parse('2014-08-11 01:00'),
                 weekly_recurring: false

    availabilities = Event.availabilities DateTime.parse('2014-08-10')
    expect(availabilities[0][:date]).to eq Date.new(2014, 8, 10)
    expect(availabilities[0][:slots]).to eq ['23:00', '23:30']
    expect(availabilities[1][:date]).to eq Date.new(2014, 8, 11)
    expect(availabilities[1][:slots]).to eq []
  end

  it "does not take into account appointments "\
     "that do not match openings" do
    Event.create kind: 'opening',
                 starts_at: DateTime.parse('2014-08-10 11:30'),
                 ends_at: DateTime.parse('2014-08-10 14:30'),
                 weekly_recurring: false

    Event.create kind: 'appointment',
                 starts_at: DateTime.parse('2014-08-10 12:00'),
                 ends_at: DateTime.parse('2014-08-10 13:30')

    Event.create kind: 'appointment',
                 starts_at: DateTime.parse('2014-08-10 15:30'),
                 ends_at: DateTime.parse('2014-08-10 16:30')

    availabilities = Event.availabilities DateTime.parse('2014-08-10')
    expect(availabilities[0][:slots]).to eq ['11:30', '13:30', '14:00']
  end

  it "does not show timeslots for the openings with the same time in "\
     "starts_at and ends_at" do
    Event.create kind: 'opening',
                 starts_at: DateTime.parse('2014-08-10 11:30'),
                 ends_at: DateTime.parse('2014-08-10 12:30'),
                 weekly_recurring: false

    Event.create kind: 'opening',
                 starts_at: DateTime.parse('2014-08-10 13:30'),
                 ends_at: DateTime.parse('2014-08-10 13:30'),
                 weekly_recurring: false

    availabilities = Event.availabilities DateTime.parse('2014-08-10')
    expect(availabilities[0][:slots]).to eq ['11:30', '12:00']
  end
end
