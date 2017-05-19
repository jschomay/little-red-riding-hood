module.exports = function(loadStory, interactWithStoryWorld, storyWorldUpdate){
  var boot = require('./boot');
  var preload = require('./preload');
  var woods = require('./woods');


  var game = new Phaser.Game(400, 300, Phaser.AUTO, '');
  game.loadStory = function(){loadStory(true)};
  game.interactWithStoryWorld = interactWithStoryWorld;
  storyWorldUpdate(updateWorld.bind(game));

  game.state.add('Boot', boot);
  game.state.add('Preload', preload);
  game.state.add('Woods', woods);

  game.state.start('Boot');
}

function updateWorld(newWorld) {
    this.worldModel = newWorld;

    // load scene?
    if (this.state.current !== newWorld.currentLocation) {
      this.state.start(newWorld.currentLocation);
    } else {
      var currentInteractables = this.state.states[this.state.current].interactables;

      // remove departed interacables
      currentInteractables.forEach(function(interactable){
        if(!member(newWorld.interactables, interactable.eneId)) {
          interactable.destroy();
        }
      });

      // add arrived interactables
      newWorld.interactables.forEach(function(interactable) {
        if(currentInteractables.filter(function(item){
          return item.eneId === interactable
        }, true).total) {
          // TODO create interactable
          // not needed for current story
        }
      });
    }

    console.log(newWorld.narrative)
}

function member(group, item) {
  return group.indexOf(item) >= 0;
}
