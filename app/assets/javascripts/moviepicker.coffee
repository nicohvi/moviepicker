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

# events
$(document).on 'keyup', '#query', (event) ->
  movieButton.trigger('click') if event.which == 13

# streams
movieClickStream = Rx.Observable.fromEvent movieButton, 'click'

requestStream = movieClickStream
  .map ->
    movieName = $('#query').val()
    $('#query').val('')
    "/movies/list?movie=#{movieName}"

responseStream = requestStream
  .flatMap (requestUrl) ->
    Rx.Observable.fromPromise($.getJSON(requestUrl))

responseStream.subscribe(
  (json) ->
    movieField.text('')
    for movie in json.movies
      movieField.append movieTemplate(movie)
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

