module Manifest exposing (items, locations, characters)

import ClientTypes exposing (..)
import Dict exposing (Dict)


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


addSprite : { x : Int, y : Int, w : Int, h : Int } -> Entity -> Entity
addSprite s =
    addComponent "sprite" (Sprite s)


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


items : List Entity
items =
    [ item "Cape" "Little Red Ridding Hood's namesake."
        |> addSprite { x = 600, y = 150, w = 70, h = 140 }
    , item "Basket of food" "Some goodies to take to Grandma."
        |> addSprite { x = 450, y = 300, w = 70, h = 70 }
    ]


characters : List Entity
characters =
    [ character "Little Red Ridding Hood" "Sweet and innocent, she spent her days playing around her cottage where she lived with her mother."
        |> addSprite { x = 730, y = 230, w = 70, h = 140 }
    , character "Mother" "Little Red Ridding Hood's mother, who looks after her."
        |> addSprite { x = 250, y = 150, w = 100, h = 250 }
    , character "Wolf" "A very sly and clever wolf, who lives in the woods."
    , character "Grandma" "Little Red Ridding Hood's grandmother, who lives alone in a cottage in the woods."
    ]


locations : List Entity
locations =
    [ location "Cottage" "The cottage where Little Red Ridding Hood and her mother live."
        |> addExits [ ( East, "River" ) ]
        |> addSprite { x = 0, y = 50, w = 300, h = 400 }
        |> addBackgroundForeground "cottage-bg.jpg" Nothing
    , location "River" "A river that runs by Little Red Ridding Hood's cottage."
        |> addExits [ ( West, "Cottage" ), ( East, "Woods" ) ]
        |> addSprite { x = 900, y = 250, w = 300, h = 200 }
        |> addBackgroundForeground "woods-bg.jpg" Nothing
    , location "Woods" "The forests that surround Little Red Ridding Hood's cottage."
        |> addExits [ ( West, "River" ), ( East, "Grandma's house" ) ]
        |> addSprite { x = 900, y = 250, w = 300, h = 200 }
    , location "Grandma's house" "The cabin in the woods where Grandma lives alone."
    ]
