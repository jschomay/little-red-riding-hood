require( './styles/main.css' );

var game = require( './phaser/game.js' );

// start Elm worker
var Elm = require( './elm/Main' );
var ene = Elm.Main.worker();

// start Phaser game
game(ene.ports.load.send, ene.ports.interact.send, ene.ports.storyWorldUpdate.subscribe);
