# variables
movieButton = $('#movie-button')
errorField  = $('.error') 
movieField  = $('.movies')
movieTemplate = Handlebars.compile($('#movie-template').html())

# functions
createClickStream = ->
  movies = $('.movie')
  clickStream = Rx.Observable.fromEvent movies, 'click'
  
  clickStream
    .map (event) ->
      $(event.delegateTarget)

disableForm = ->
  movieButton.attr('disabled', true)
  $('#query').val('')
  $('<div>')
    .addClass('spinner')
    .appendTo(movieField)

enableForm = ->
  movieButton.attr('disabled', false)

# events
$(document).on 'keyup', '#query', (event) ->
  movieButton.trigger('click') if event.which == 13

# streams
movieClickStream = Rx.Observable.fromEvent movieButton, 'click'

requestStream = movieClickStream
  .map ->
    movieField.text('')
    movieName = $('#query').val()
    "/movies/list?movie=#{movieName}"

responseStream = requestStream
  .flatMap (requestUrl) ->
    disableForm()
    Rx.Observable.fromPromise($.getJSON(requestUrl))

# subscription
responseStream.subscribe(
  (json) ->
    movies = []
    for movie in json.movies
      movies.push movieTemplate(movie)
    movieField.html(movies)
    enableForm()
    clickStream = createClickStream()

    clickStream.subscribe(
      (movie) ->
        $('.active').removeClass('active')
        movie.addClass('active')
    )
  ,
  (error) ->
    errorField.text('Something went wrong, try again maybe?')
)

