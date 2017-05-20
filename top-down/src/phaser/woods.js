var Woods = function(){};

Woods.prototype = {
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
    this.createInteractables();


    var story = this.game.add.graphics(0, 0);
    story.beginFill(0x000000, 1);
    story.drawRect(0, 0, this.game.width, this.game.height / 4);
    story.fixedToCamera = true;

    this.narrative = this.game.add.bitmapText(10, 10, 'font', this.game.worldModel.narrative, 12);
    this.game.cache.getBitmapFont('font').font.lineHeight = 130;
    this.narrative.maxWidth = this.game.width - 10;
    story.addChild(this.narrative)


    //create player
    var result = findObjectsByType('player', this.map, 'interact')
     
    //we know there is just one result
    this.player = this.game.add.sprite(result[0].x, result[0].y, 'lrrh');
    this.game.physics.arcade.enable(this.player);
    this.player.body.setSize(32, 32, 0, 0);
     
    //the camera will follow the player in the world
    this.game.camera.follow(this.player);
     
    //move player with cursor keys
    this.cursors = this.game.input.keyboard.createCursorKeys();

    this.previousInteraction = null;

    // listen to updates from ene
    this.game.storyWorldUpdates.add(updateWorld, this);
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
    this.game.physics.arcade.collide(this.player, this.interactables, this.interact, null, this);
  },

  render: function() {
    this.interactables.forEach(function(x){
      this.game.debug.body(x);
    }, this);
  },

  collect: function(player, collectable) {
    //remove sprite
    collectable.destroy();
  },

  interact: function(player, interacable) {
    if(this.previousInteraction !== interacable.eneId) {
      this.previousInteraction = interacable.eneId;
      this.game.interactWithStoryWorld(interacable.eneId);
    };
  },

  createItems: function() {
    //create items
    this.items = this.game.add.group();
    this.items.enableBody = true;
    var results = findObjectsByType('item', this.map, 'interact');
    results.forEach(function(element){
      createFromTiledObject(element, this.items);
    }, this);
  },

  createInteractables: function() {
    this.interactables = this.game.add.group();
    this.interactables.enableBody = true;

    findInteractables(this.map, 'interact').forEach(function(element){
      if(member(this.game.worldModel.interactables, element.properties.eneId)) {
        createFromTiledObject(element, this.interactables);
      }
    }, this);

    this.interactables.setAll('body.immovable', true);
  }
}

function findObjectsByType(type, map, layer) {
  var result = new Array();
  map.objects[layer].forEach(function(element){
    if(element.properties.type === type) {
      element.y -= map.tileHeight;
      result.push(element);
    }      
  });
  return result;
}

function findInteractables(map, layer) {
  var result = new Array();
  map.objects[layer].forEach(function(element){
    if(element.properties.eneId) {
      // element.y -= map.tileHeight;
      result.push(element);
    }      
  });
  return result;
}

function createFromTiledObject(element, group) {
  var sprite = group.create(element.x, element.y, element.properties.sprite);

  Object.keys(element.properties).forEach(function(key){
    sprite[key] = element.properties[key];
  });
  if(element.properties.type === 'exit') {
    sprite.body.width = element.width;
    sprite.body.height = element.height;
  }
}

function updateWorld(newWorld) {
    this.game.worldModel = newWorld;

    // load new scene?
    if (this.state.current !== newWorld.currentLocation) {
      this.state.start(newWorld.currentLocation);
    } else {
      // update story text
      this.narrative.setText(this.game.worldModel.narrative);

      // remove departed interacables
      this.interactables.forEach(function(interactable){
        if(!member(newWorld.interactables, interactable.eneId)) {
          interactable.destroy();
        }
      });

      // add arrived interactables
      newWorld.interactables.forEach(function(interactable) {
        if(this.interactables.filter(function(item){
          return item.eneId === interactable
        }, true).total) {
          // TODO create interactable
          // not needed for current story
        }
      }, this);
    }
}

function member(group, item) {
  return group.indexOf(item) >= 0;
}
module.exports = Woods;
