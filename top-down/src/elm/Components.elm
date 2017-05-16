module Components exposing (..)

import ClientTypes exposing (..)
import Dict


getDisplay : Entity -> { name : String, description : String }
getDisplay entity =
    let
        errorMsg =
            "Error: no Display component information found for enity id: " ++ entity.id
    in
        Dict.get "display" entity.components
            |> Maybe.andThen
                (\c ->
                    case c of
                        Display d ->
                            Just d

                        _ ->
                            Nothing
                )
            |> Maybe.withDefault { name = errorMsg, description = errorMsg }


getExits : Entity -> Exits
getExits entity =
    case Dict.get "connectedLocations" entity.components of
        Just (ConnectedLocations exits) ->
            exits

        _ ->
            []


getSprite :
    Entity
    -> Maybe
        { texture : String
        , position : ( Float, Float )
        , size : ( Float, Float )
        , bottomLeft : ( Float, Float )
        , topRight : ( Float, Float )
        , numberOfFrames : Int
        , duration : Float
        }
getSprite entity =
    case Dict.get "sprite" entity.components of
        Just (Sprite s) ->
            Just s

        _ ->
            Nothing
