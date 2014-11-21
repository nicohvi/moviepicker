# variables
queryButton       = $('#query-button')
errorField        = $('.error') 
moviesContainer   = $('.movies')
movieContainer    = $('#movie')
movieListTemplate = Handlebars.compile $('#movie-list-template').html()
movieTemplate     = Handlebars.compile $('#movie-template').html()

# functions

disableForm = ->
  queryButton.attr('disabled', true)
  $('#query').val('')
  $('<div>')
    .addClass('spinner')
    .appendTo(moviesContainer)

enableForm = ->
  queryButton.attr('disabled', false)

# events

$(document).on 'keyup', '#query', (event) ->
  queryButton.trigger('click') if event.which == 13

# streams

clickStream = Rx.Observable.fromEvent document, 'click'

queryClicks = clickStream
  .filter (event) ->
    $(event.target).attr('id') == 'query-button'

movieClicks = clickStream
  .debounce(500)
  .filter (event) ->
    $(event.target).hasClass('movie') || $(event.target).parents('.movie').length > 0

movieIDs = movieClicks
  .map (event) ->
    if $(event.target).hasClass('movie')
      $(event.target).data('id')
    else
      $(event.target).parents('.movie:first').data('id')

searchURLs = queryClicks
  .map ->
    movieName = $('#query').val()
    disableForm()
    "/movies/list?movie=#{movieName}"

similarMovieURLs = movieIDs
  .map (id) ->
    "/movies/similar/#{id}"

requests  = Rx.Observable.merge(searchURLs, similarMovieURLs)

responses = requests
  .flatMap (requestUrl) ->
    Rx.Observable.fromPromise $.getJSON(requestUrl)

jsonResponses = responses.publish()

movieListHTML = jsonResponses
  .filter (json) ->
    json.movies?
  .map (json) ->
    _.map(json.movies, (movie) -> movieListTemplate(movie))

movieHTML = jsonResponses
  .filter (json) ->
    json.movie != null
  .map (json) ->
    movieTemplate(json.movie)

# subscriptions

movieListHTML.subscribe(
  (html) ->
    moviesContainer.html(html)
    enableForm()
)

movieHTML.subscribe(
  (html) ->
    movieContainer.html(html)
)


jsonResponses.connect()
