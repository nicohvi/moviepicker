# variables

queryButton       = $('#query-button')
errorField        = $('.error') 
moviesContainer   = $('.movies')
movieContainer    = $('#movie')
movieListTemplate = Handlebars.compile $('#movie-list-template').html()
movieTemplate     = Handlebars.compile $('#movie-template').html()
movie             = ''
suggestedMovies   = []

# functions

disableForm = ->
  moviesContainer.text('')
  movieContainer.text('')
  $('#movie').removeClass('show')
  queryButton.attr('disabled', true)
  $('#query').val('')

spin = -> $('.spinner').addClass('show')
unspin = -> $('.spinner').removeClass('show')

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
      $(event.target)
    else
      $(event.target).parents('.movie:first')

movieCache = movieClicks
  .filter (movieElement) ->
    suggestedMovies.length != 0 || movie == movieElement.find('.title').text()

movieIDs = movieClicks
  .filter (movieElement) ->
    suggestedMovies.length == 0 || movie != movieElement.find('.title').text()
  .map (movieElement) ->
    if $('.active').data('tomato_id') != movieElement.data('tomato_id')
      $('.active').removeClass('active')
      movieElement.addClass('active')
    $('#movie').removeClass('show')
    movie = movieElement.find('.title').text()
    { tomatoID: movieElement.data('tomatoId'), imdbID: movieElement.data('imdbId') }

searchURLs = queryClicks
  .map ->
    movieName = $('#query').val()
    disableForm()
    "/movies/search?movie=#{movieName}"

similarMovieURLs = movieIDs
  .map (id) ->
    "/movies/similar?tomato_id=#{id.tomatoID}&imdb_id=#{id.imdbID}"

requests  = Rx.Observable.merge(searchURLs, similarMovieURLs)

responses = requests
  .flatMap (requestUrl) ->
    spin()
    Rx.Observable.fromPromise $.getJSON(requestUrl)

# Turn into hot source
jsonResponses = responses.publish()

movieJSON     = jsonResponses
  .filter (json) -> !json.total?
  .map  (json) -> suggestedMovies = json

movieListJSON = jsonResponses.filter (json) -> json.total?

movieListHTML = movieListJSON
  .map (json) ->
    _.map(json.movies, (movie) -> movieListTemplate(movie))

movieHTML = movieCache
  .merge(movieJSON)
  .map ->
    if suggestedMovies.length > 0
      suggestion = _.sample(suggestedMovies)
      index = suggestedMovies.indexOf(suggestion)
      suggestedMovies.splice(index, 1)
      movieTemplate(suggestion)
    else
      "Sorry, no suggeted movies for that one - get better taste please."
   
# subscriptions

movieListHTML.subscribe(
  (html) ->
    unspin()
    moviesContainer.html(html)
    enableForm()
)

movieHTML.subscribe(
  (html) ->
    unspin()
    $('#movie').addClass('show')
    movieContainer.html(html)
)

closeClicks.subscribe(
  -> $('#movie').toggleClass('show')
)

jsonResponses.connect()
