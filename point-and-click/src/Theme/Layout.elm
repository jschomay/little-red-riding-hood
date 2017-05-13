module Theme.Layout exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Keyed
import Html.Events exposing (..)
import ClientTypes exposing (..)
import Components exposing (..)
import Markdown
import Engine


view :
    { currentLocation : Entity
    , itemsInCurrentLocation : List Entity
    , charactersInCurrentLocation : List Entity
    , exits : List ( Direction, Entity )
    , itemsInInventory : List Entity
    , ending : Maybe String
    , story : String
    , engineModel : Engine.Model
    }
    -> Html Msg
view displayState =
    let
        ( bg, fg ) =
            getBackgroundForeground displayState.currentLocation

        backGroundImage bg =
            style [ ( "backgroundImage", "url(img/" ++ bg ++ ")" ) ]

        spriteStyle x y z w h =
            style
                [ ( "left", toString x ++ "px" )
                , ( "top", toString y ++ "px" )
                , ( "width", toString w ++ "px" )
                , ( "height", toString h ++ "px" )
                , ( "zIndex", toString z )
                ]

        background =
            [ div [ class "background", backGroundImage bg ] [] ]

        fromConditional =
            Maybe.andThen (Engine.chooseFrom displayState.engineModel >> Maybe.map .value)

        sprites =
            displayState.charactersInCurrentLocation
                ++ displayState.itemsInCurrentLocation
                ++ List.map Tuple.second displayState.exits
                |> List.filterMap
                    (\entity ->
                        getSprite entity
                            |> fromConditional
                            |> Maybe.map
                                (\{ x, y, z, w, h } ->
                                    div
                                        (List.filterMap identity
                                            [ Just <| class <| "sprite " ++ (getStyle entity |> fromConditional |> Maybe.withDefault "")
                                            , Just <| spriteStyle x y z w h
                                            , Just <| onClick <| Interact entity.id
                                            , getImage entity
                                                |> fromConditional
                                                |> Maybe.map backGroundImage
                                            ]
                                        )
                                        []
                                )
                    )

        foreground =
            Maybe.map
                (\fg ->
                    [ div [ class <| "foreground", backGroundImage fg ] [] ]
                )
                fg
                |> Maybe.withDefault []

        story =
            [ Html.Keyed.node "div" [] [ ( displayState.story, Markdown.toHtml [ class "story" ] displayState.story ) ] ]
    in
        div [ class "container" ]
            [ div [ class <| "game game--" ++ (getStyle displayState.currentLocation |> fromConditional |> Maybe.withDefault "default") ] <|
                []
                    ++ background
                    ++ sprites
                    ++ foreground
                    ++ story
            ]
