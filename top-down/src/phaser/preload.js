//loading the game assets
var Preload = function(){};

Preload.prototype = {
  preload: function() {
    //show loading screen
    this.preloadBar = this.add.sprite(this.game.world.centerX, this.game.world.centerY + 128, 'preloadbar');
    this.preloadBar.anchor.setTo(0.5);

    this.load.setPreloadSprite(this.preloadBar);

    //load game assets
    this.load.tilemap('woods', 'woods-tile-map.json', null, Phaser.Tilemap.TILED_JSON);
    this.load.image('forest-tileset', 'img/forest-tileset.png');
    this.load.image('lrrh', 'img/lrrh.png');
    this.load.image('wolf', 'img/wolf.png');
    this.load.image('flower', 'img/flower.png');
  },
  create: function() {
    this.game.loadStory();
  }
};


module.exports = Preload;
