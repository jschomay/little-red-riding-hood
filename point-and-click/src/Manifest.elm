module Manifest exposing (items, locations, characters)

import ClientTypes exposing (..)
import Dict exposing (Dict)
import Engine exposing (..)


display : String -> String -> Components
display name description =
    Dict.fromList [ ( "display", Display { name = name, description = description } ) ]


addStyle : String -> Components -> Components
addStyle selector components =
    Dict.insert "style" (Style selector) components


addExits : List ( Direction, String ) -> Entity -> Entity
addExits exits =
    addComponent "connectedLocations" (ConnectedLocations exits)


addBackgroundForeground : String -> Maybe String -> Entity -> Entity
addBackgroundForeground background foreground =
    addComponent "backgroundForeground" (BackgroundForeground background foreground)


addSprite : Conditional { x : Int, y : Int, w : Int, h : Int } -> Entity -> Entity
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
            |> addStyle name
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
        |> addSprite (noConditionals { x = 490, y = 310, w = 33, h = 220 })
        |> addImage (noConditionals "cape.png")
    , item "Basket of food" "Some goodies to take to Grandma."
        |> addSprite (noConditionals { x = 290, y = 465, w = 140, h = 90 })
        |> addImage (noConditionals "basket.png")
    ]


characters : List Entity
characters =
    [ character "Little Red Ridding Hood" "Sweet and innocent, she spent her days playing around her cottage where she lived with her mother."
        |> addSprite
            [ { conditions = [ currentLocationIs "Cottage" ], value = { x = 590, y = 275, w = 144, h = 280 } }
            , { conditions = [ currentLocationIs "Cottage", itemIsInInventory "Cape", itemIsInInventory "Basket of food" ], value = { x = 590, y = 275, w = 195, h = 280 } }
            , { conditions = [ currentLocationIs "River" ], value = { x = 130, y = 270, w = 110, h = 160 } }
            , { conditions = [ currentLocationIs "Woods" ], value = { x = 200, y = 390, w = 100, h = 150 } }
            , { conditions = [ currentLocationIs "Woods2" ], value = { x = 200, y = 390, w = 100, h = 150 } }
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
            , { conditions = [ currentLocationIs "River" ]
              , value = "lrrh-river.png"
              }
            ]
    , character "Mother" "Little Red Ridding Hood's mother, who looks after her."
        |> addSprite (noConditionals { x = 100, y = 145, w = 280, h = 410 })
        |> addImage (noConditionals "mother.png")
    , character "Wolf" "A very sly and clever wolf, who lives in the woods."
        |> addSprite
            [ { conditions = [ currentLocationIs "Woods" ], value = { x = 340, y = 120, w = 500, h = 420 } }
            , { conditions = [ currentLocationIs "Woods2" ], value = { x = 330, y = 220, w = 490, h = 320 } }
            , { conditions = [ currentLocationIs "Grandma's house" ], value = { x = 520, y = 130, w = 350, h = 320 } }
            ]
    , character "Grandma" "Little Red Ridding Hood's grandmother, who lives alone in a cottage in the woods."
    ]


locations : List Entity
locations =
    [ location "Cottage" "The cottage where Little Red Ridding Hood and her mother live."
        |> addExits [ ( East, "River" ) ]
        |> addSprite (noConditionals { x = 0, y = 140, w = 100, h = 300 })
        |> addBackgroundForeground "cottage.jpg" Nothing
    , location "River" "A river that runs by Little Red Ridding Hood's cottage."
        |> addExits [ ( West, "Cottage" ), ( East, "Woods" ) ]
        |> addSprite
            [ { conditions = [ currentLocationIs "Cottage" ]
              , value = { x = 890, y = 180, w = 40, h = 400 }
              }
            , { conditions = [ currentLocationIs "Woods" ]
              , value = { x = 0, y = 250, w = 300, h = 200 }
              }
            ]
        |> addBackgroundForeground "river.jpg" Nothing
    , location "Woods" "The forests that surround Little Red Ridding Hood's cottage."
        |> addSprite (noConditionals { x = 750, y = 130, w = 180, h = 320 })
        |> addBackgroundForeground "woods.jpg" Nothing
    , location "Woods2" "The forests that surround Little Red Ridding Hood's cottage."
        |> addExits [ ( East, "Grandma's house" ) ]
        |> addBackgroundForeground "woods2.jpg" Nothing
    , location "Grandma's house" "The cabin in the woods where Grandma lives alone."
        |> addBackgroundForeground "grandmas-house.jpg" Nothing
        |> addSprite (noConditionals { x = 800, y = 270, w = 100, h = 270 })
    ]
