class Event < ApplicationRecord
  SCAN_DAYS = 7

  class << self
    def availabilities(start_date)
      result = []
      current_date = start_date
      SCAN_DAYS.times do |i|
        app_slots = appointment_slots(current_date)
        op_slots = opening_slots(current_date)
        slots = (op_slots - app_slots).sort.map! do |s|
          s[0, 5].delete_prefix('0')
        end
        result << { date: current_date, slots: slots}
        current_date = start_date + (i + 1).days
      end
      result
    end

    private

    def appointment_slots(date)
      connection
        .select_all(
          sanitize_sql_array(
            [select_str << appointment_where_clause,
             'appointment',
             date.beginning_of_day,
             date.end_of_day + 1.day]))
        .rows
        .flatten
        .uniq
    end

    def opening_slots(date)
      connection
        .select_all(
          sanitize_sql_array(
            [select_str << opening_where_clause,
             'opening',
             false,
             date,
             date + 1.day,
             true,
             date + 1.day,
             date.wday]))
        .rows
        .flatten
        .uniq
    end

    def select_str
      "SELECT DISTINCT (
           generate_series (
               events.starts_at,
               (events.ends_at - '30 minutes'::interval),
               '30 minutes'::interval
           )
       )::time as slots
       FROM events "
    end

    def appointment_where_clause
      "WHERE kind = ? AND (starts_at >= ? AND ends_at <= ?)"
    end

    def opening_where_clause
      "WHERE kind = ? AND (
           weekly_recurring = ? AND (
               starts_at >= ? AND starts_at < ?
           ) OR weekly_recurring = ? AND (
               starts_at < ? AND EXTRACT(DOW FROM starts_at) = ?
           )
       )"
    end
  end
end
