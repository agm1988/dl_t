class Event < ApplicationRecord
  SCAN_DAYS = 7
  INTERVAL = 30.minutes

  scope :openings, -> { where(kind: 'opening') }
  scope :appointments, -> { where(kind: 'appointment') }
  scope :recurring, -> { openings.where(weekly_recurring: true) }
  scope :not_recurring, -> { openings.where(weekly_recurring: false) }
  scope :asc_by_starts_at, -> { order('starts_at asc') }

  scope :openings_by_date, lambda { |date|
    not_recurring
      .where('starts_at > ?', date)
      .where('starts_at < ?', date + 1.day)
      .or(recurring
            .where('starts_at < ?', date)
            .where('EXTRACT(DOW FROM starts_at) = ?', date.wday))
  }

  scope :appointments_by_date, lambda { |date|
    appointments.where('starts_at <= ?', date).where('ends_at > ?', date)
  }

  class << self
    def availabilities(start_date)
      result = []
      i = 0
      current_date = start_date
      loop do
        break if current_date >= start_date + SCAN_DAYS.days
        result << { date: current_date, slots: slots(current_date) }
        i += 1
        current_date = start_date + i.days
      end
      result
    end

    private

    def slots(current_date)
      openings = openings_by_date(current_date)
      return [] if !openings.exists? || is_weekend?(current_date)
      openings.map{ |o| slots_for_opening(o, current_date) }.flatten
    end

    def is_weekend?(date)
      date.sunday? || date.saturday?
    end

    def slots_for_opening(opening, date)
      result = []
      starts_at = opening.starts_at
      loop do
        break if (starts_at + INTERVAL) > opening.ends_at
        result << starts_at.strftime('%-H:%M') unless booked?(date, starts_at)
        starts_at += INTERVAL
      end
      result
    end

    def booked?(date, time)
      datetime_str = [date.strftime('%F'), time.strftime('%H:%M')].join(' ')
      appointments_by_date(DateTime.parse(datetime_str)).exists?
    end
  end
end
