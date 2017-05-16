module Manifest exposing (items, locations, characters)

import ClientTypes exposing (..)
import Dict exposing (Dict)


display : String -> String -> Components
display name description =
    Dict.fromList [ ( "display", Display { name = name, description = description } ) ]


addExits : List ( Direction, String ) -> Entity -> Entity
addExits exits =
    addComponent "connectedLocations" (ConnectedLocations exits)


addSprite :
    { texture : String
    , position : ( Float, Float )
    , size : ( Float, Float )
    , bottomLeft : ( Float, Float )
    , topRight : ( Float, Float )
    , numberOfFrames : Int
    , duration : Float
    }
    -> Entity
    -> Entity
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
    [ item "Cape" "Little Red Riding Hood's namesake."
    , item "Basket of food" "Some goodies to take to Grandma."
    ]


characters : List Entity
characters =
    [ character "Little Red Riding Hood" "Sweet and innocent, she spent her days playing around her cottage where she lived with her mother."
    , character "Mother" "Little Red Riding Hood's mother, who looks after her."
        |> addSprite
            { texture = "img/sprites.png"
            , position = ( -2, -2 )
            , size = ( 1.5, 1.5 )
            , bottomLeft = ( 0, 0.77 )
            , topRight = ( 0.18, 1 )
            , numberOfFrames = 1
            , duration = 1
            }
    , character "Wolf" "A very sly and clever wolf, who lives in the woods."
    , character "Grandma" "Little Red Riding Hood's grandmother, who lives alone in a cottage in the woods."
    ]


locations : List Entity
locations =
    [ location "Cottage" "The cottage where Little Red Riding Hood and her mother live."
        |> addSprite
            { texture = "img/cottage.png"
            , position = ( -4, -4 )
            , size = ( 10, 10 )
            , bottomLeft = ( 0, 0 )
            , topRight = ( 1, 1 )
            , numberOfFrames = 1
            , duration = 1
            }
    , location "River" "A river that runs by Little Red Riding Hood's cottage."
    , location "Woods" "The forests that surround Little Red Riding Hood's cottage."
    , location "Grandma's house" "The cabin in the woods where Grandma lives alone."
    ]
