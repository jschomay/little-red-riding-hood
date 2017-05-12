module Manifest exposing (items, locations, characters)

import ClientTypes exposing (..)
import Dict exposing (Dict)
import Engine exposing (..)


display : String -> String -> Components
display name description =
    Dict.fromList [ ( "display", Display { name = name, description = description } ) ]


addStyle : Conditional String -> Entity -> Entity
addStyle selector =
    addComponent "style" (Style selector)


addExits : List ( Direction, String ) -> Entity -> Entity
addExits exits =
    addComponent "connectedLocations" (ConnectedLocations exits)


addBackgroundForeground : String -> Maybe String -> Entity -> Entity
addBackgroundForeground background foreground =
    addComponent "backgroundForeground" (BackgroundForeground background foreground)


addSprite : Conditional { x : Int, y : Int, z : Int, w : Int, h : Int } -> Entity -> Entity
addSprite s =
    addComponent "sprite" (Sprite s)


addImage : Conditional String -> Entity -> Entity
addImage i =
    addComponent "image" (Image i)


addComponent : String -> Component -> Entity -> Entity
addComponent key componentData entity =
    { entity | components = Dict.insert key componentData entity.components }


item : String -> String -> Entity
item name description =
    { id = name
    , components = display name description
    }


location : String -> String -> Entity
location name description =
    { id = name
    , components =
        display name description
    }


character : String -> String -> Entity
character name description =
    { id = name
    , components = display name description
    }


noConditionals : a -> Conditional a
noConditionals a =
    [ { conditions = [], value = a } ]


items : List Entity
items =
    [ item "Cape" "Little Red Ridding Hood's namesake."
        |> addSprite (noConditionals { x = 490, y = 310, z = 1, w = 33, h = 220 })
        |> addImage (noConditionals "cape.png")
    , item "Basket of food" "Some goodies to take to Grandma."
        |> addSprite (noConditionals { x = 290, y = 465, z = 2, w = 140, h = 90 })
        |> addImage (noConditionals "basket.png")
    , item "Tree" "Just a tree"
        |> addSprite (noConditionals { x = 550, y = 0, z = 2, w = 221, h = 545 })
        |> addImage (noConditionals "tree.png")
        |> addStyle (noConditionals "tree")
    , item "Small tree" "Just a tree"
        |> addSprite (noConditionals { x = 20, y = 0, z = 2, w = 169, h = 545 })
        |> addImage (noConditionals "small-tree.png")
        |> addStyle (noConditionals "tree")
    , item "Signpost" "Grandma's house: 1mi that way ->."
        |> addSprite (noConditionals { x = 830, y = 445, z = 3, w = 103, h = 100 })
        |> addImage (noConditionals "sign.png")
    , item "Bedpost" "Just part of the bed"
        |> addSprite (noConditionals { x = 420, y = 272, z = 2, w = 41, h = 270 })
        |> addImage (noConditionals "bedpost.png")
        |> addStyle (noConditionals "bedpost")
    ]


characters : List Entity
characters =
    [ character "Little Red Ridding Hood" "Sweet and innocent, she spent her days playing around her cottage where she lived with her mother."
        |> addStyle
            [ { conditions = [ currentLocationIs "River" ], value = "lrrh-river" }
            , { conditions = [ currentLocationIs "Woods" ], value = "lrrh-woods" }
            , { conditions = [ currentLocationIs "Woods", currentSceneIs "Wolf!" ], value = "lrrh-retreat" }
            , { conditions = [ currentLocationIs "Woods", currentSceneIs "bye bye Grannie" ], value = "lrrh-retreat" }
            , { conditions = [ currentLocationIs "Grandma's house" ], value = "lrrh-grandmas-house" }
            ]
        |> addSprite
            [ { conditions = [ currentLocationIs "Cottage" ], value = { x = 550, y = 275, z = 2, w = 144, h = 280 } }
            , { conditions = [ currentLocationIs "Cottage", itemIsInInventory "Cape", itemIsInInventory "Basket of food" ], value = { x = 450, y = 275, z = 2, w = 195, h = 280 } }
            , { conditions = [ currentLocationIs "River" ], value = { x = 190, y = 270, z = 1, w = 110, h = 160 } }
            , { conditions = [ currentLocationIs "Woods" ], value = { x = 180, y = 405, z = 2, w = 100, h = 140 } }
            , { conditions = [ currentLocationIs "Grandma's house" ], value = { x = 130, y = 255, z = 1, w = 195, h = 280 } }
            ]
        |> addImage
            [ { conditions = [ currentLocationIs "Cottage", itemIsNotInInventory "Cape", itemIsNotInInventory "Basket of food" ]
              , value = "lrrh-empty.png"
              }
            , { conditions = [ currentLocationIs "Cottage", itemIsInInventory "Cape" ]
              , value = "lrrh-cape.png"
              }
            , { conditions = [ currentLocationIs "Cottage", itemIsInInventory "Basket of food" ]
              , value = "lrrh-basket.png"
              }
            , { conditions = [ currentLocationIs "Cottage", itemIsInInventory "Basket of food", itemIsInInventory "Cape" ]
              , value = "lrrh.png"
              }
            , { conditions = []
              , value = "lrrh.png"
              }
            ]
    , character "Mother" "Little Red Ridding Hood's mother, who looks after her."
        |> addSprite (noConditionals { x = 100, y = 145, z = 1, w = 280, h = 410 })
        |> addImage (noConditionals "mother.png")
    , character "Wolf" "A very sly and clever wolf, who lives in the woods."
        |> addStyle
            [ { conditions = [ currentLocationIs "Woods", currentSceneIs "Wolf!" ], value = "wolf-approach" }
            , { conditions = [ currentLocationIs "Woods", currentSceneIs "bye bye Grannie" ], value = "wolf-retreat" }
            ]
        |> addSprite
            [ { conditions = [ currentLocationIs "Woods" ], value = { x = 100, y = 100, z = 1, w = 779, h = 450 } }
            , { conditions = [ currentLocationIs "Woods", currentSceneIs "Wolf!" ], value = { x = 300, y = 120, z = 3, w = 1018, h = 429 } }
            , { conditions = [ currentLocationIs "Woods", currentSceneIs "bye bye Grannie" ], value = { x = 260, y = 120, z = 3, w = 1018, h = 429 } }
            , { conditions = [ currentLocationIs "Grandma's house" ], value = { x = 380, y = 95, z = 1, w = 480, h = 293 } }
            ]
        |> addImage
            [ { conditions = [ currentLocationIs "Woods", hasNotPreviouslyInteractedWith "Wolf" ], value = "wolf-hiding.png" }
            , { conditions = [ currentLocationIs "Woods", hasPreviouslyInteractedWith "Wolf" ], value = "wolf.png" }
            , { conditions = [ currentLocationIs "Grandma's house" ], value = "wolf-as-grandma.png" }
            ]
    , character "Grandma" "Little Red Ridding Hood's grandmother, who lives alone in a cottage in the woods."
        |> addSprite (noConditionals { x = 520, y = 135, z = 1, w = 280, h = 410 })
        |> addImage (noConditionals "grandma.png")
    ]


locations : List Entity
locations =
    [ location "Cottage" "The cottage where Little Red Ridding Hood and her mother live."
        |> addExits [ ( East, "River" ) ]
        |> addSprite (noConditionals { x = 0, y = 140, z = 1, w = 100, h = 300 })
        |> addBackgroundForeground "cottage.jpg" Nothing
    , location "River" "A river that runs by Little Red Ridding Hood's cottage."
        |> addExits [ ( West, "Cottage" ), ( East, "Woods" ) ]
        |> addImage
            [ { conditions = [ currentLocationIs "Cottage" ]
              , value = "cottage-door.png"
              }
            ]
        |> addSprite
            [ { conditions = [ currentLocationIs "Cottage" ]
              , value = { x = 590, y = 58, z = 1, w = 217, h = 500 }
              }
            , { conditions = [ currentLocationIs "Woods" ]
              , value = { x = 0, y = 250, z = 1, w = 300, h = 200 }
              }
            ]
        |> addBackgroundForeground "river.jpg" Nothing
    , location "Woods" "The forests that surround Little Red Ridding Hood's cottage."
        |> addSprite (noConditionals { x = 620, y = 30, z = 1, w = 310, h = 420 })
        |> addBackgroundForeground "woods-bg.jpg" (Just "woods-fg.png")
    , location "Grandma's house" "The cabin in the woods where Grandma lives alone."
        |> addBackgroundForeground "grandmas-house.jpg" Nothing
        |> addSprite (noConditionals { x = 800, y = 270, z = 1, w = 100, h = 270 })
    ]
