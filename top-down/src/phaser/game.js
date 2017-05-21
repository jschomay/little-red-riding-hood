module.exports = function(loadStory, interactWithStoryWorld, storyWorldUpdates){
  var boot = require('./boot');
  var preload = require('./preload');
  var cottage = require('./cottage');
  var woods = require('./woods');

  var game = new Phaser.Game(500, 400, Phaser.AUTO, '');
  game.loadStory = function(){loadStory(true)};
  game.interactWithStoryWorld = interactWithStoryWorld;
  game.storyWorldUpdates = new Phaser.Signal();
  // turn elm messages into phaser signals
  storyWorldUpdates(function(x){ game.storyWorldUpdates.dispatch(x) });

  game.state.add('Boot', boot);
  game.state.add('Preload', preload);
  game.state.add('Cottage', cottage);
  game.state.add('Woods', woods);

  game.state.start('Boot');
}

