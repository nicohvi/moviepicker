# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Movie.create(
  [ { name: 'Up', rating: 8.3, release_year: 2009 },
    { name: 'What if?', rating: 6.9, release_year: 2013},
    { name: 'Goon', rating: 6.8, release_year: 2011},
    { name: 'Interstellar', rating: 9.0, release_year: 2014},
    { name: 'Boyhood', rating: 8.5, release_year: 2014}])
