module ClientTypes exposing (..)

import Dict exposing (Dict)
import Engine exposing (Condition)


type Msg
    = Interact Id
    | FromJS String


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


type alias Conditional a =
    List
        { conditions : List Condition
        , value : a
        }


type Component
    = None


type alias Entity =
    { id : String
    , components : Components
    }
