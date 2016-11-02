# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

users = User.where(login: %w(first_driver second_driver))
users.each { |u| u.truck&.destroy }
users.destroy_all

first_driver = User.create!(login: 'first_driver', password: '111111', role: 'driver')
second_driver = User.create!(login: 'second_driver', password: '111111', role: 'driver')

Truck.create!(max_weight: 10_000, max_volume: 1400, user_id: first_driver.id)
Truck.create!(max_weight: 10_000, max_volume: 1400, user_id: second_driver.id)


User.where(login: 'dispatcher').destroy_all
User.create!(login: 'dispatcher', password: '111111', role: 'dispatcher')
