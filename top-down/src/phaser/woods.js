var Level = require('./level');

module.exports =  Woods = function () { Level.call(this); };
Woods.prototype = Object.create(Level.prototype);
Woods.prototype.constructor = Woods;
Woods.prototype.setUpMap = setUpMap;

function setUpMap() {
  this.map = this.game.add.tilemap('woods');
  this.map.addTilesetImage('terrain', 'woods-terrain');
  this.map.addTilesetImage('water', 'woods-water');
  this.map.addTilesetImage('features', 'woods-features');

  this.bgLayer = this.map.createLayer('bg');
  this.bg2Layer = this.map.createLayer('bg2');
  this.bgLayer.resizeWorld();

  this.solidLayer = this.map.createLayer('solid');
  this.map.setCollisionBetween(1, 2000, true, 'solid');
};
