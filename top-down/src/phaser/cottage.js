var Level = require('./level');

module.exports =  Cottage = function () { Level.call(this); };
Cottage.prototype = Object.create(Level.prototype);
Cottage.prototype.constructor = Cottage;
Cottage.prototype.setUpMap = setUpMap;

function setUpMap() {
  this.map = this.game.add.tilemap('cottage');
  this.map.addTilesetImage('cottage', 'cottage-tileset');

  this.bgLayer = this.map.createLayer('bg');
  this.bgLayer.resizeWorld();

  this.solidLayer = this.map.createLayer('solid');
  this.map.setCollisionBetween(1, 2000, true, 'solid');
};
