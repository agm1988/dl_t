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
      .where('starts_at >= ? AND starts_at < ?',
             date,
             date + 1.day)
      .or(recurring
            .where('starts_at < ? AND EXTRACT(DOW FROM starts_at) = ?',
                   date + 1.day,
                   date.wday))
      .asc_by_starts_at
  }

  scope :appointments_by_date, lambda { |date|
    appointments.where('starts_at >= ? AND ends_at <= ?',
                       date.beginning_of_day,
                       date.end_of_day + (SCAN_DAYS-1).days)
  }

  class << self
    def availabilities(start_date)
      result = []
      current_date = start_date
      appointments = appointments_by_date(current_date)
                       .pluck(:starts_at, :ends_at)
      SCAN_DAYS.times do |i|
        result << { date: current_date,
                    slots: slots(current_date, appointments) }
        current_date = start_date + (i+1).days
      end
      result
    end

    private

    def slots(current_date, appointments)
      openings = openings_by_date(current_date)
                   .pluck(:starts_at, :ends_at)
      return [] unless openings.length > 0
      openings.map! do |o|
        slots_for_opening(o, appointments, current_date)
      end
      openings.flatten.uniq
    end

    def slots_for_opening(opening, appointments, date)
      result = []
      starts_at = opening[0]
      loop do
        break if last_slot?(opening, starts_at + INTERVAL)
        unless booked?(appointments, date, starts_at)
          result << starts_at.strftime('%-H:%M')
        end
        starts_at += INTERVAL
      end
      result
    end

    def last_slot?(opening, starts_at)
      starts_at > opening[1] ||
        starts_at > opening[0].tomorrow.beginning_of_day
    end

    def booked?(appointments, date, time)
      return false unless appointments.length > 0
      date_str = date.strftime('%F')
      time_str = time.strftime('%H:%M')
      datetime = DateTime.new(date_str[0, 4].to_i,
                              date_str[5, 2].to_i,
                              date_str[8, 2].to_i,
                              time_str[0, 2].to_i,
                              time_str[3,2].to_i)
      appointments.count { |x| x[0] <= datetime && x[1] > datetime } > 0
    end
  end
end
