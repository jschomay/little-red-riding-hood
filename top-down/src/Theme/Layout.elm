module Theme.Layout exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Keyed
import Html.Events exposing (..)
import ClientTypes exposing (..)
import Components exposing (..)
import Markdown
import Engine
import Game.TwoD as Game
import Game.TwoD.Camera as Camera
import Game.TwoD.Render as Render exposing (Renderable)
import Color exposing (..)


view :
    { currentLocation : Entity
    , itemsInCurrentLocation : List Entity
    , charactersInCurrentLocation : List Entity
    , exits : List ( Direction, Entity )
    , itemsInInventory : List Entity
    , ending : Maybe String
    , story : String
    , engineModel : Engine.Model
    , lrrh : LRRH
    }
    -> Html Msg
view displayState =
    let
        ( bg, fg ) =
            getBackgroundForeground displayState.currentLocation

        backGroundImage bg =
            style [ ( "backgroundImage", "url(img/" ++ bg ++ ")" ) ]

        sizeAttrs x y w h =
            style
                [ ( "left", toString x ++ "px" )
                , ( "top", toString y ++ "px" )
                , ( "width", toString w ++ "px" )
                , ( "height", toString h ++ "px" )
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
                                (\{ x, y, w, h } ->
                                    div
                                        (List.filterMap identity
                                            [ Just <| class "sprite"
                                            , Just <| sizeAttrs x y w h
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

        camera =
            Camera.fixedArea (100) ( 0, 0 )

        lrrh =
            Render.shape Render.rectangle { color = red, position = ( displayState.lrrh.x, displayState.lrrh.y ), size = ( 1, 1 ) }
    in
        div [ class "container" ]
            [ Game.render { time = 0, size = ( 800, 600 ), camera = camera }
                [ lrrh ]
            ]
