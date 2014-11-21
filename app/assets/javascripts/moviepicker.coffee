# variables
queryButton       = $('#query-button')
errorField        = $('.error') 
moviesContainer   = $('.movies')
movieContainer    = $('#movie')
movieListTemplate = Handlebars.compile $('#movie-list-template').html()
movieTemplate     = Handlebars.compile $('#movie-template').html()
baseMovieId       = 0
# functions

disableForm = ->
  moviesContainer.text('')
  movieContainer.text('')
  $('#movie').removeClass('show')
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

closeClicks = clickStream
  .filter (event) ->
    $(event.target).attr('id') == 'movie'

movieClicks = clickStream
  .debounce(500)
  .filter (event) ->
    $(event.target).hasClass('movie') || $(event.target).parents('.movie').length > 0
  .map (event) ->
    if $(event.target).hasClass('movie')
      $el = $(event.target)
    else
      $el = $(event.target).parents('.movie:first')

movieIDs = movieClicks
  .map (movie) ->
    if $('.active').data('id') != movie.data('id')
      $('.active').removeClass('active')
      movie.addClass('active')
    $('#movie').removeClass('show')
    movie.data('id')

searchURLs = queryClicks
  .map ->
    movieName = $('#query').val()
    disableForm()
    "/movies/list?movie=#{movieName}"

similarMovieURLs = movieIDs
  .map (id) ->
    baseMovieId = id
    "/movies/similar/#{id}"

requests  = Rx.Observable.merge(searchURLs, similarMovieURLs)

responses = requests
  .flatMap (requestUrl) ->
    Rx.Observable.fromPromise $.getJSON(requestUrl)

jsonResponses = responses.publish()

movieJSON     = jsonResponses.filter (json) -> !json.total?
movieListJSON = jsonResponses.filter (json) -> json.total?

movieListHTML = movieListJSON
  .map (json) ->
    _.map(json.movies, (movie) -> movieListTemplate(movie))

movieHTML = movieJSON
  .map (json) ->
    if json.movies.length > 0
      movieTemplate _.sample(json.movies)
    else
      "Sorry, no suggeted movies for that one - get better taste please."

# subscriptions

movieListHTML.subscribe(
  (html) ->
    moviesContainer.html(html)
    enableForm()
)

movieHTML.subscribe(
  (html) ->
    $('#movie').addClass('show')
    console.log 'cqllad'
    movieContainer.html(html)
)

closeClicks.subscribe(
  -> $('#movie').toggleClass('show')
)

jsonResponses.connect()
