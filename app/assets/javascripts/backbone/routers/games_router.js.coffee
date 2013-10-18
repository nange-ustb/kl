class LotteryGame.Routers.GamesRouter extends Backbone.Router
  initialize: (options) ->
    @games = new LotteryGame.Collections.GamesCollection()
    @games.reset options.games

  routes:
    "new"      : "newGame"
    "index"    : "index"
    ":id/edit" : "edit"
    ":id"      : "show"
    ".*"        : "index"

  newGame: ->
    @view = new LotteryGame.Views.Games.NewView(collection: @games)
    $("#games").html(@view.render().el)

  index: ->
    @view = new LotteryGame.Views.Games.IndexView(games: @games)
    $("#games").html(@view.render().el)

  show: (id) ->
    game = @games.get(id)

    @view = new LotteryGame.Views.Games.ShowView(model: game)
    $("#games").html(@view.render().el)

  edit: (id) ->
    game = @games.get(id)

    @view = new LotteryGame.Views.Games.EditView(model: game)
    $("#games").html(@view.render().el)
