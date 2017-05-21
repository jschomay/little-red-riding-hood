var Cottage = function(){};

Cottage.prototype = {
  create: function() {
    this.map = this.game.add.tilemap('cottage');
    this.map.addTilesetImage('cottage', 'cottage-tileset');

    this.bgLayer = this.map.createLayer('bg');
    this.bgLayer.resizeWorld();

    this.solidLayer = this.map.createLayer('solid');
    this.map.setCollisionBetween(1, 2000, true, 'solid');

    this.interactables = this.game.add.group();
    this.interactables.enableBody = true;

    this.addInteractables();

    var story = this.game.add.graphics(0, this.game.height - this.game.height / 4);
    story.beginFill(0x000000, 1);
    story.drawRect(0, 0, this.game.width, this.game.height / 4);
    story.fixedToCamera = true;
    this.narrative = this.game.add.bitmapText(10, 10, 'font', this.game.worldModel.narrative, 12);
    this.game.cache.getBitmapFont('font').font.lineHeight = 130;
    this.narrative.maxWidth = this.game.width - 10;
    story.addChild(this.narrative)

    var result = findObjectsByType('player', this.map, 'interactables')[0];
    this.player = this.game.add.sprite(result.x, result.y, 'lrrh');
    this.game.physics.arcade.enable(this.player);
    this.player.body.setSize(25, 38, 6, 8);

    this.game.camera.follow(this.player, 0, 1, 1);
     
    this.cursors = this.game.input.keyboard.createCursorKeys();

    this.previousInteraction = null;

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
    this.game.physics.arcade.collide(this.player, this.interactables, this.interact, null, this);
  },

  render: function() {
    // this.interactables.forEach(function(x){
    //   this.game.debug.body(x);
    // }, this);
      // this.game.debug.body(this.player);
  },

  interact: function(player, interacable) {
    if(this.previousInteraction !== interacable.eneId) {
      this.previousInteraction = interacable.eneId;
      this.game.interactWithStoryWorld(interacable.eneId);
    };
  },

  addInteractables: function() {
    findInteractables(this.map, 'interactables').forEach(function(element){
      if(member(this.game.worldModel.interactables, element.properties.eneId)) {
        createFromTiledObject(element, this.interactables);
      }
    }, this);

    this.interactables.setAll('body.immovable', true);
  },
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
  if(element.properties.type === 'zone') {
    sprite.body.width = element.width;
    sprite.body.height = element.height;
  } else {
    sprite.y -= sprite.height;
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
module.exports = Cottage;
