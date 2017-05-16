module ClientTypes exposing (..)

import Dict exposing (Dict)
import Engine exposing (Condition)
import Keyboard.Extra
import Game.Resources as Resources exposing (Resources)


type alias LRRH =
    { x : Float
    , y : Float
    , vx : Float
    , vy : Float
    }


type Msg
    = Interact Id
    | Loaded
    | Tick Float
    | Keys Keyboard.Extra.Msg
    | Resources Resources.Msg


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
    = Display { name : String, description : String }
    | ConnectedLocations Exits
    | Bounds { top : Float, bottom : Float, left : Float, right : Float }
    | Sprite
        { texture : String
        , position : ( Float, Float )
        , size : ( Float, Float )
        , bottomLeft : ( Float, Float )
        , topRight : ( Float, Float )
        , numberOfFrames : Int
        , duration : Float
        }


type alias Entity =
    { id : String
    , components : Components
    }
