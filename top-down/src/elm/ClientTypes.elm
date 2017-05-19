module ClientTypes exposing (..)

import Dict exposing (Dict)
import Engine exposing (Condition)


type Msg
    = Interact Id
    | Load


type alias StoryWorld =
    { currentLocation : String
    , narrative : String
    , interactables : List String
    }


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
    List String


type Component
    = ConnectedLocations Exits


type alias Entity =
    { id : String
    , components : Components
    }
