class LotteryGame.Models.Game extends Backbone.Model
  paramRoot: 'game'

  #设置默认值
  defaults:
    title: null
    code: null

class LotteryGame.Collections.GamesCollection extends Backbone.Collection
  model: LotteryGame.Models.Game
  url: '/games'
