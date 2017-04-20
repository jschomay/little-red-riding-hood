module Theme.Locations exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import ClientTypes exposing (..)
import Components exposing (..)


view :
    List ( Direction, Entity )
    -> Entity
    -> Html Msg
view exits currentLocation =
    let
        exitsList =
            exits
                |> List.map
                    (\( direction, entity ) ->
                        p
                            []
                            [ span
                                [ class "CurrentSummary__StoryElement u-selectable"
                                , onClick <| Interact entity.id
                                ]
                                [ text <| .name <| getDisplay entity ]
                            , text <| " is to the " ++ toString direction ++ "."
                            ]
                    )
                |> div []
    in
        div [ class "Locations" ]
            [ h3 [] [ text "Connecting locations" ]
            , div [ class "Locations__list" ]
                [ exitsList ]
            ]
