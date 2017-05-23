var Level = require('./level');

module.exports =  GrandmasHouse = function () { Level.call(this); };
GrandmasHouse.prototype = Object.create(Level.prototype);
GrandmasHouse.prototype.constructor = Cottage;
GrandmasHouse.prototype.setUpMap = setUpMap;

function setUpMap() {
  this.map = this.game.add.tilemap('grandmas-house');
  this.map.addTilesetImage('cottage', 'cottage-tileset');

  this.bgLayer = this.map.createLayer('bg');
  this.bgLayer.resizeWorld();

  this.solidLayer = this.map.createLayer('solid');
  this.map.setCollisionBetween(1, 2000, true, 'solid');
};
