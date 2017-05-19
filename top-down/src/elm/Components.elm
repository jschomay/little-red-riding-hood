module Components exposing (..)

import ClientTypes exposing (..)
import Dict


getExits : Entity -> Exits
getExits entity =
    case Dict.get "connectedLocations" entity.components of
        Just (ConnectedLocations exits) ->
            exits

        _ ->
            []
