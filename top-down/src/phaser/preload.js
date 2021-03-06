//loading the game assets
var Preload = function(){};

Preload.prototype = {
  preload: function() {
    //show loading screen
    this.preloadBar = this.add.sprite(this.game.world.centerX, this.game.world.centerY, 'preloadbar');
    this.preloadBar.anchor.setTo(0.5);

    this.load.setPreloadSprite(this.preloadBar);

    //load game assets
    this.load.tilemap('cottage', 'tilemaps/cottage.json', null, Phaser.Tilemap.TILED_JSON);
    this.load.tilemap('woods', 'tilemaps/woods.json', null, Phaser.Tilemap.TILED_JSON);
    this.load.tilemap('grandmas-house', 'tilemaps/grandmas-house.json', null, Phaser.Tilemap.TILED_JSON);

    this.load.image('cottage-tileset', 'img/cottage-tileset.png');
    this.load.image('woods-terrain', 'img/woods-terrain.png');
    this.load.image('woods-water', 'img/woods-water.png');
    this.load.image('woods-features', 'img/woods-features.png');
    this.load.spritesheet('lrrh', 'img/lrrh-walking.png', 48, 48);
    this.load.image('mother', 'img/mother.png');
    this.load.image('basket', 'img/basket.png');
    this.load.image('wolf', 'img/wolf.png');
    this.load.image('grandma', 'img/grandma.png');
    this.load.image('wolf-grandma', 'img/wolf-grandma.png');
    this.load.bitmapFont('font', 'img/font.png', 'img/font.fnt');

    // for the touch control plugin; these won't be visible
    this.load.image('compass', 'img/lrrh.png');
    this.load.image('touch_segment', 'img/lrrh.png');
    this.load.image('touch', 'img/lrrh.png');
  },
  create: function() {
    this.game.storyWorldUpdates.addOnce(start, this);
    this.game.loadStory();
  }
};

function start(newWorld) {
  this.game.worldModel = newWorld
  this.state.start(newWorld.currentLocation);
}

module.exports = Preload;
