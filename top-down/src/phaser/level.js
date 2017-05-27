var Level = function(){};

Level.prototype = {
  create: function() {
    //this.setUpMap must be defined in the scene that inherits from this super class, and must add a tilemap with the appropriate tilesets and layers
    this.setUpMap.call(this);

    this.interactables = this.game.add.group();
    this.interactables.enableBody = true;
    this.interactables.name = 'interactables';
    this.addInteractables();
    this.interactables.setAll('body.immovable', true);

    this.zones = this.game.add.group();
    this.zones.enableBody = true;
    this.zones.name = 'zones';
    this.addZones();
    this.zones.setAll('body.immovable', true);

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
    this.player.speed = 100;
    this.player.frame = 10;
    this.player.animations.add('left', [6, 7, 8, 7], 8, true);
    this.player.animations.add('right', [3, 4, 5, 4], 8, true);
    this.player.animations.add('up', [0, 1, 2, 1], 8, true);
    this.player.animations.add('down', [9, 10, 11, 10], 8, true);

    this.game.camera.follow(this.player, 0, 1, 1);
     
    this.cursors = this.game.input.keyboard.createCursorKeys();

    this.game.touchControl = this.game.plugins.add(Phaser.Plugin.TouchControl);
    this.game.touchControl.inputEnable();
    this.game.touchControl.settings.singleDirection = true;
    this.game.touchControl.imageGroup.forEach(function(i){i.destroy();});

    this.previousInteraction = null;

    this.game.storyWorldUpdates.add(updateWorld, this);

    this.game.camera.flash(0x000000, 1000);
  },

  update: function() {
    if(this.game.worldModel.isEnd) {
      this.player.body.velocity.y = 0;
      this.player.body.velocity.x = 0;
      this.player.animations.stop();
      return true;
    }

    //player movement
    this.player.body.velocity.y = 0;
    this.player.body.velocity.x = 0;

    var direction = new Phaser.Point(0, 0);
    if(this.cursors.left.isDown || this.game.touchControl.cursors.left) {
         direction.x = -1;
    }
    else if(this.cursors.right.isDown || this.game.touchControl.cursors.right) {
         direction.x = 1;
    }
    if(this.cursors.up.isDown || this.game.touchControl.cursors.up) {
         direction.y = -1;
    }
    else if(this.cursors.down.isDown || this.game.touchControl.cursors.down) {
         direction.y = 1;
    }
    direction.normalize();

    this.player.body.velocity.x += direction.x * this.player.speed;
    this.player.body.velocity.y += direction.y * this.player.speed;

    if(direction.x > 0) {
         this.player.animations.play('right');
    }
    else if(direction.x < 0) {
         this.player.animations.play('left');
    }
    else if(direction.y > 0) {
         this.player.animations.play('down');
    }
    else if(direction.y < 0) {
         this.player.animations.play('up');
    }
    else {
        this.player.animations.stop();
    }

    //collision
    this.game.physics.arcade.collide(this.player, this.solidLayer);
    this.game.physics.arcade.collide(this.player, this.interactables, this.interact, null, this);
    this.game.physics.arcade.overlap(this.player, this.zones, this.interact, null, this);
  },

  render: function() {
    // this.interactables.forEach(function(x){
    //   this.game.debug.body(x);
    // }, this);
    // this.zones.forEach(function(x){
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
  },

  addZones: function() {
    findInteractables(this.map, 'zones').forEach(function(element){
      if(member(this.game.worldModel.interactables, element.properties.eneId)) {
        createFromTiledObject(element, this.zones);
      }
    }, this);
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
  if(group.name === 'zones') {
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
      this.game.camera.onFadeComplete.add(function() {
        this.state.start(newWorld.currentLocation);
      }, this);
      this.game.camera.fade(0x000000, 1000);
    } else {
      // update story text
      this.narrative.setText(this.game.worldModel.narrative);
      this.narrative.alpha = 0.2;
      this.game.add.tween(this.narrative).to( { alpha: 1 }, 800, "Linear", true);

      // remove departed interacables and zones
      this.interactables.forEach(function(interactable){
        if(!member(newWorld.interactables, interactable.eneId)) {
          interactable.destroy();
        }
      });
      this.zones.forEach(function(zone){
        if(!member(newWorld.interactables, zone.eneId)) {
          zone.destroy();
        }
      });

      // add arrived interactables and zones
      newWorld.interactables.forEach(function(interactable) {
        if(this.interactables.filter(function(item){
          return item.eneId === interactable
        }, true).total) {
          // TODO create interactable
          // Also do for zones
          // Not needed for current story
        }
      }, this);
    }
}

function member(group, item) {
  return group.indexOf(item) >= 0;
}
module.exports = Level;
