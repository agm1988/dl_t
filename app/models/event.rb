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
      .where('starts_at >= ?', date)
      .where('starts_at < ?', date + 1.day)
      .or(recurring
            .where('starts_at < ?', date + 1.day)
            .where('EXTRACT(DOW FROM starts_at) = ?', date.wday))
      .asc_by_starts_at
  }

  scope :appointments_by_date, lambda { |date|
    appointments
      .where('starts_at <= ?', date)
      .where('ends_at > ?', date)
      .asc_by_starts_at
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
      return [] if !openings.exists?
      openings.map{ |o| slots_for_opening(o, current_date) }.flatten.uniq
    end

    def slots_for_opening(opening, date)
      result = []
      starts_at = opening.starts_at
      loop do
        break if last_slot?(opening, starts_at)
        result << starts_at.strftime('%-H:%M') unless booked?(date, starts_at)
        starts_at += INTERVAL
      end
      result
    end

    def last_slot?(opening, current_starts_at)
      starts_at = current_starts_at + INTERVAL
      next_day_beginning = opening.starts_at.tomorrow.beginning_of_day
      starts_at > opening.ends_at || starts_at > next_day_beginning
    end

    def booked?(date, time)
      datetime_str = [date.strftime('%F'), time.strftime('%H:%M')].join(' ')
      appointments_by_date(DateTime.parse(datetime_str)).exists?
    end
  end
end
