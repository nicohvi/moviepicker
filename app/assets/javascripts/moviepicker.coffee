
movieButton = $('#movie-button')
errorField  = $('.error') 
movieField  = $('.movies')
movieTemplate = Handlebars.compile($('#movie-template').html())

$(document).on 'keyup', '#query', (event) ->
  movieButton.trigger('click') if event.which == 13

movieStream = Rx.Observable.fromEvent movieButton, 'click'

requestStream = movieStream
  .map ->
    movieName = $('#query').val()
    "/movies/list?movie=#{movieName}"

responseStream = requestStream
  .flatMap (requestUrl) ->
    Rx.Observable.fromPromise($.getJSON(requestUrl))

responseStream.subscribe(
  (json) ->
    movieField.text('')
    for movie in json.movies
      movieField.append movieTemplate(movie)
  ,
  (error) ->
    errorField.text('Something went wrong, try again maybe?')
)
