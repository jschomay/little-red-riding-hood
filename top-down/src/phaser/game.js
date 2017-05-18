module.exports = function(toENE){
  var boot = require('./boot');
  var preload = require('./preload');
  var play = require('./play');


  var game = new Phaser.Game(400, 300, Phaser.AUTO, '');
  game.toENE = toENE;

  game.state.add('Boot', boot);
  game.state.add('Preload', preload);
  game.state.add('Play', play);

  game.state.start('Boot');
  toENE('hi from game')
}
