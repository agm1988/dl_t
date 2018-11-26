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

  class << self
    def availabilities(start_date)
      end_date = start_date + SCAN_DAYS.days
      result = []
      i = 0
      current_result_date = start_date

      loop do
        break if current_result_date >= end_date
        result << {}
        result[i][:date] = current_result_date
        openings = openings_by_date(current_result_date)
        result[i][:slots] = slots(current_result_date, openings)
        i += 1
        current_result_date = start_date + i.days
      end

      result
    end

    private

    def slots(current_result_date, openings)
      result = []
      return result if openings.length == 0 || current_result_date.sunday? || current_result_date.saturday?
      openings.each do |o|
        current_starts_at = o.starts_at
        loop do
          break if (current_starts_at + INTERVAL) > o.ends_at
          result << current_starts_at.strftime('%-H:%M')
          current_starts_at += INTERVAL
        end
      end
      result.uniq
    end
  end

end
