require( './styles/reset.css' );
require( './styles/main.css' );
require( './styles/story.css' );
require( './styles/github-markdown.css' );

var startGame = require( './phaser/game.js' );

// inject bundled Elm app
var Elm = require( './elm/Main' );
var ene = Elm.Main.worker();

startGame(ene.ports.toElm.send);

ene.ports.fromElm.subscribe(function(x){
  console.log(x);
});
