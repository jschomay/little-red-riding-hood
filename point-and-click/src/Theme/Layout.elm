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
    , scaleRatio : Float
    , loaded : Bool
    , temptWolf : Int
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
                [ ( "left", toString (toFloat x * displayState.scaleRatio) ++ "px" )
                , ( "top", toString (toFloat y * displayState.scaleRatio) ++ "px" )
                , ( "width", toString (toFloat w * displayState.scaleRatio) ++ "px" )
                , ( "height", toString (toFloat h * displayState.scaleRatio) ++ "px" )
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
            Html.Keyed.node "div" [ class "story" ] [ ( displayState.story, Markdown.toHtml [] displayState.story ) ]
    in
        div [ class "container" ] <|
            [ div
                [ class <|
                    "game game--"
                        ++ (getStyle displayState.currentLocation |> fromConditional |> Maybe.withDefault "default")
                        ++ (" tempt-wolf-" ++ toString displayState.temptWolf)
                ]
              <|
                if not displayState.loaded then
                    [ div [ class "loading" ] [ span [] [ text "Loading..." ] ] ]
                else
                    []
                        ++ background
                        ++ sprites
                        ++ foreground
                        ++ [ div [ class "vignette" ] [] ]
                        ++ if displayState.ending /= Nothing then
                            [ div [ class "ending" ]
                                [ h2 [] [ text "The End" ]
                                , p [] [ text "Game by Jeff Schomay" ]
                                , p [] [ text "Art by Samuel Herb" ]
                                ]
                            ]
                           else
                            []
            , if displayState.loaded then
                story
              else
                div [ class "story" ] []
            ]
