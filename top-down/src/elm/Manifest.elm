module Manifest exposing (items, locations, characters)

import ClientTypes exposing (..)
import Dict exposing (Dict)


addComponent : String -> Component -> Entity -> Entity
addComponent key componentData entity =
    { entity | components = Dict.insert key componentData entity.components }


addExits : List String -> Entity -> Entity
addExits exits =
    addComponent "connectedLocations" (ConnectedLocations exits)


item : String -> String -> Entity
item name description =
    { id = name
    , components = Dict.empty
    }


location : String -> String -> Entity
location name description =
    { id = name
    , components = Dict.empty
    }


character : String -> String -> Entity
character name description =
    { id = name
    , components = Dict.empty
    }


items : List Entity
items =
    [ item "Cape" "Little Red Riding Hood's namesake."
    , item "Basket of food" "Some goodies to take to Grandma."
    ]


characters : List Entity
characters =
    [ character "Little Red Riding Hood" "Sweet and innocent, she spent her days playing around her cottage where she lived with her mother."
    , character "Mother" "Little Red Riding Hood's mother, who looks after her."
    , character "Wolf" "A very sly and clever wolf, who lives in the woods."
    , character "Grandma" "Little Red Riding Hood's grandmother, who lives alone in a cottage in the woods."
    ]


locations : List Entity
locations =
    [ location "Cottage" "The cottage where Little Red Riding Hood and her mother live."
    , location "River" "A river that runs by Little Red Riding Hood's cottage."
    , location "Woods" "The forests that surround Little Red Riding Hood's cottage."
        |> addExits [ "Grandma's house" ]
    , location "Grandma's house" "The cabin in the woods where Grandma lives alone."
    ]
