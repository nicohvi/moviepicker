# variables

queryButton       = $('#query-button')
query             = $('#query')
spinner           = $('.spinner')
movieListTemplate = Handlebars.compile $('#movie-list-template').html()
movieTemplate     = Handlebars.compile $('#movie-template').html()
movieCache        = {}
movieList         = $('.movies')
suggestedMovie    = $('#movie')

# functions

resolve = (url) ->
  return Bacon.once(movieCache[url]) if movieCache[url]? && !_.isEmpty(movieCache[url])
  Bacon.fromPromise($.getJSON(url)).flatMap (json) -> movieCache[url] = json

toggleRequest = ->
    suggestedMovie.removeClass('show')
    spinner.toggleClass('show')
    query.val('')
    queryButton.prop 'disabled', (index, oldValue) -> !oldValue

# streams

keyStream = $(document).asEventStream('keyup')

enterKeys = keyStream
  .filter (event) ->
    event.which == 13

queryURLStream = queryButton.asEventStream('click')
  .merge(enterKeys)
  .filter ->
    query.val().length > 1
  .map ->
    movie = query.val()
    "/movies/search?movie=#{movie}"

movieURLStream = $('body').asEventStream('click', '.movie')
  .debounce(500)
  .map (event) ->
    $movie = $(event.currentTarget)
    "/movies/similar?tomato_id=#{$movie.data('tomatoId')}&imdb_id=#{$movie.data('imdbId')}"
 
requestStream   = queryURLStream.merge(movieURLStream)

responseStream  = requestStream.flatMap(resolve)

movieListStream = responseStream
  .filter (json) -> json.total?
  .map    (json) -> _.map(json.movies, (movie) -> movieListTemplate(movie))

movieStream     = responseStream
  .filter (json) -> !json.total?
  .map    (json) -> movieTemplate _.bob(json)

requestInProgress = requestStream.merge(responseStream)

# observers

requestInProgress.onValue -> toggleRequest()
movieListStream.onValue (html) -> movieList.html(html)
movieStream.onValue     (html) -> suggestedMovie.html(html).addClass('show')

    
