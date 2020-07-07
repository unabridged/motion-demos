# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

password = "ABCabc123!@"

users = User.create([
  {name: "Wendy", email: "wendy@unabridgedsoftware.com", password: password},
  {name: "Alec", email: "alec@unabridgedsoftware.com", password: password},
  {name: "Drew", email: "drew@unabridgedsoftware.com", password: password},
  {name: "Lexie", email: "lexie@unabridgedsoftware.com", password: password}
])
users = User.all.to_a

user_sets = users.permutation(2)

messages = [
  "Could you send that to me?",
  "Great job!",
  "The report rocked.",
  "Let's set up a meeting first thing Monday.",
  "We all loved it.",
  "I'm following up from last week.",
  "What thoughts does the team have?"
]

user_sets.each do |user_set|
  from = user_set.first
  to = user_set.last
  4.times { |i| Message.create(from: from, to: to, content: messages.sample, created_at: Date.current - i.days) }
end
