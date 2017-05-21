module Manifest exposing (items, locations, characters)

import ClientTypes exposing (..)
import Dict exposing (Dict)


addComponent : String -> Component -> Entity -> Entity
addComponent key componentData entity =
    { entity | components = Dict.insert key componentData entity.components }


addExits : List String -> Entity -> Entity
addExits exits =
    addComponent "connectedLocations" (ConnectedLocations exits)


item : String -> Entity
item id =
    { id = id
    , components = Dict.empty
    }


location : String -> Entity
location id =
    { id = id
    , components = Dict.empty
    }


character : String -> Entity
character id =
    { id = id
    , components = Dict.empty
    }


items : List Entity
items =
    [ item "Basket of food"
    , item "Bridge"
    ]


characters : List Entity
characters =
    [ character "Little Red Riding Hood"
    , character "Mother"
    , character "Wolf"
    , character "Grandma"
    ]


locations : List Entity
locations =
    [ location "Cottage" |> addExits [ "Woods" ]
    , location "Woods" |> addExits [ "Cottage", "Grandma's house" ]
    , location "Grandma's house"
    ]
