# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

initial_date = DateTime.parse('2014-08-04 09:00')

def recurring?
  Event.recurring.count < 2 && rand(1..1000) == 1
end

10000.times do |i|
  Event.create kind: 'opening',
               starts_at: initial_date + [0, 30].sample.minutes,
               ends_at: initial_date + [120, 180, 240].sample.minutes,
               weekly_recurring: recurring?

  Event.create kind: 'appointment',
               starts_at: initial_date + [30, 60].sample.minutes,
               ends_at: initial_date + [90, 120].sample.minutes

  Event.create kind: 'opening',
               starts_at: initial_date + [300, 330, 360].sample.minutes,
               ends_at: initial_date + [480, 540, 720].sample.minutes,
               weekly_recurring: recurring?

  Event.create kind: 'appointment',
               starts_at: initial_date + [390, 420].sample.minutes,
               ends_at: initial_date + [450, 480].sample.minutes

  initial_date += 1.day
end
