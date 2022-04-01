# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create(username: "admin", email: "admin@overwatch.com", password: "5y5t3mp455123456", admin: true, regular_user: false, viewer: false, first_name: "Overwatch", last_name: "ADMIN")
