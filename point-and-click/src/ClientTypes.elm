module ClientTypes exposing (..)

import Dict exposing (Dict)


type Msg
    = Interact Id
    | Loaded


type alias Id =
    String


type alias RuleData a =
    { a
        | summary : String
        , narrative : Narrative
    }


type alias Narrative =
    List String


type alias Components =
    Dict String Component


type Direction
    = North
    | South
    | East
    | West


type alias Exits =
    List ( Direction, String )


type Component
    = Display { name : String, description : String }
    | Style String
    | ConnectedLocations Exits
    | BackgroundForeground String (Maybe String)
    | Sprite { x : Int, y : Int, w : Int, h : Int }


type alias Entity =
    { id : String
    , components : Components
    }
