module Theme.Inventory exposing (..)

import Html exposing (..)
import Html.Keyed
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import ClientTypes exposing (..)
import Components exposing (..)


view :
    List Entity
    -> Html Msg
view items =
    let
        numItems =
            List.length items

        inventoryItem i entity =
            let
                key =
                    (toString entity.id) ++ (toString <| numItems - i)
            in
                ( key
                , li
                    [ class "Inventory__Item u-selectable"
                    , onClick <| Interact entity.id
                    ]
                    [ text <| .name <| getDisplay entity ]
                )
    in
        div [ class "Inventory" ]
            [ h3 [] [ text "Inventory" ]
            , div [ class "Inventory__list" ]
                [ Html.Keyed.ol []
                    (List.indexedMap inventoryItem items)
                ]
            ]
