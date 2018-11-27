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

  it 'raises ArgumentError if passing date is invalid'
  it 'returns an empty array if there are no openings'
  it 'returns one timeslot if the opening lasts 30 minutes'
  it 'returns date with its openings timeslots'
  it 'returns array of multiple dates with their openings timeslots'
  it 'returns dates ordered'
  it 'returns timeslots ordered within dates'
  it 'keeps order of timeslots of different openings for the same date'
  it 'returns timeslots starting with 00:00'
  it 'returns timeslots up to 24:00'
  it 'returns date with adjacent timeslots of different openings'
  it 'returns adjacent dates with adjacent timeslots'
  it 'does not return opening timeslots when they are booked'
  it "does not return any timeslots of the opening "\
     "that was booked completely with the same appointment"
  it "does not return adjacent timeslots from different openings "\
     "booked with the same appointment"
  it 'does not return any opening timeslots when they are all booked'

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

  it 'does not count duplicate timeslots twice'
  it "returns the correct sets of opening timeslots "\
     "when there are overlapping appointments"
  it "does not count timeslots after 24:00 of the opening "\
     "which has ends_at with the next day"
  it "does not take into account erroneous appointments "\
     "(those that do not match openings)"
  it "does not show timeslots for the openings with the same time in "\
     "starts_at and ends_at"
end
