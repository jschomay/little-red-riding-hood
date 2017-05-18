//title screen
var Play = function(){};

Play.prototype = {
  create: function() {
    this.map = this.game.add.tilemap('woods');

    //the first parameter is the tileset name as specified in Tiled, the second is the key to the asset
    this.map.addTilesetImage('forest', 'forest-tileset');

    //create layer
    this.bgLayer = this.map.createLayer('bg');
    this.solidLayer = this.map.createLayer('solid');

    //collision on blockedLayer
    this.map.setCollisionBetween(1, 2000, true, 'solid');

    //resizes the game world to match the layer dimensions
    this.bgLayer.resizeWorld();

    this.createItems();

    //create wolf
    var result = findObjectsByType('wolf', this.map, 'interact')
     
    //we know there is just one result
    this.wolf = this.game.add.sprite(result[0].x, result[0].y, 'wolf');
    this.game.physics.arcade.enable(this.wolf);
     
    //create player
    result = findObjectsByType('player', this.map, 'interact')
     
    //we know there is just one result
    this.player = this.game.add.sprite(result[0].x, result[0].y, 'lrrh');
    this.game.physics.arcade.enable(this.player);
    this.player.body.setSize(32, 32, 0, 0);
     
    //the camera will follow the player in the world
    this.game.camera.follow(this.player);
     
    //move player with cursor keys
    this.cursors = this.game.input.keyboard.createCursorKeys();
  },

  update: function() {
    var speed = 100;
    //player movement
    this.player.body.velocity.y = 0;
    this.player.body.velocity.x = 0;
 
    if(this.cursors.up.isDown) {
      this.player.body.velocity.y -= speed;
    }
    else if(this.cursors.down.isDown) {
      this.player.body.velocity.y += speed;
    }
    if(this.cursors.left.isDown) {
      this.player.body.velocity.x -= speed;
    }
    else if(this.cursors.right.isDown) {
      this.player.body.velocity.x += speed;
    }

    //collision
    this.game.physics.arcade.collide(this.player, this.solidLayer);
    this.game.physics.arcade.overlap(this.player, this.items, this.collect, null, this);
    // this.game.physics.arcade.overlap(this.player, this.wolf, this.wolf, null, this);
  },

  collect: function(player, collectable) {
    this.game.toENE('yummy!');

    //remove sprite
    collectable.destroy();
  },
  createItems: function() {
    //create items
    this.items = this.game.add.group();
    this.items.enableBody = true;
    var item;    
    result = findObjectsByType('item', this.map, 'interact');
    result.forEach(function(element){
      createFromTiledObject(element, this.items);
    }, this);
  },
}


 //find objects in a Tiled layer that containt a property called "type" equal to a certain value
function findObjectsByType(type, map, layer) {
  var result = new Array();
  map.objects[layer].forEach(function(element){
    if(element.properties.type === type) {
      //Phaser uses top left, Tiled bottom left so we have to adjust the y position
      //also keep in mind that the cup images are a bit smaller than the tile which is 16x16
      //so they might not be placed in the exact pixel position as in Tiled
      element.y -= map.tileHeight;
      result.push(element);
    }      
  });
  return result;
}

//create a sprite from an object
function createFromTiledObject(element, group) {
  var sprite = group.create(element.x, element.y, element.properties.sprite);

  //copy all properties to the sprite
  Object.keys(element.properties).forEach(function(key){
    sprite[key] = element.properties[key];
  });
}

module.exports = Play;
