var Level = require('./level');

module.exports =  GrandmasHouse = function () { Level.call(this); };
GrandmasHouse.prototype = Object.create(Level.prototype);
GrandmasHouse.prototype.constructor = Cottage;
GrandmasHouse.prototype.setUpMap = setUpMap;
GrandmasHouse.prototype.create = create;
GrandmasHouse.prototype.update = update;

function setUpMap() {
  this.map = this.game.add.tilemap('grandmas-house');
  this.map.addTilesetImage('cottage', 'cottage-tileset');

  this.bgLayer = this.map.createLayer('bg');
  this.bgLayer.resizeWorld();

  this.solidLayer = this.map.createLayer('solid');
  this.map.setCollisionBetween(1, 2000, true, 'solid');
};

function create() {
    Level.prototype.create.call(this);
    this.theEnd = this.game.add.bitmapText(170, 120, 'font', "The End", 22);
    this.theEnd.visible = false;
}

function update() {
    Level.prototype.update.call(this);
    if(this.game.worldModel.isEnd && !this.theEnd.visible) {

      this.theEnd.visible = true;

      this.player.speed = 0;

      // attack!
      var wolf = this.interactables.filter(function(item){
        return item.key === 'wolf-grandma';
      }).first;
      this.game.add.tween(wolf).to( { x: this.player.body.x + this.player.width, y: this.player.body.y - this.player.height / 2 }, 200, "Linear", true);
      }
}
