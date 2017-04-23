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


getStyle : Entity -> String
getStyle entity =
    let
        errorMsg =
            "Error: no Style component information found for enity id: " ++ entity.id
    in
        Dict.get "style" entity.components
            |> Maybe.andThen
                (\c ->
                    case c of
                        Style s ->
                            Just s

                        _ ->
                            Nothing
                )
            |> Maybe.withDefault errorMsg


getExits : Entity -> Exits
getExits entity =
    case Dict.get "connectedLocations" entity.components of
        Just (ConnectedLocations exits) ->
            exits

        _ ->
            []


getBackgroundForeground : Entity -> ( String, Maybe String )
getBackgroundForeground entity =
    case Dict.get "backgroundForeground" entity.components of
        Just (BackgroundForeground bg fg) ->
            ( bg, fg )

        _ ->
            ( "empty", Nothing )


getSprite : Entity -> Maybe { x : Int, y : Int, w : Int, h : Int }
getSprite entity =
    case Dict.get "sprite" entity.components of
        Just (Sprite s) ->
            Just s

        _ ->
            Nothing
