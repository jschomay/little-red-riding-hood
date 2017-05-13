port module Main exposing (..)

import Engine exposing (..)
import Manifest exposing (..)
import Rules exposing (rulesData)
import Html exposing (..)
import Html.Attributes exposing (..)
import Theme.Layout
import ClientTypes exposing (..)
import Components exposing (..)
import Dict exposing (Dict)
import List.Zipper as Zipper exposing (Zipper)


type alias Model =
    { engineModel : Engine.Model
    , loaded : Bool
    , storyLine : List String
    , content : Dict String (Maybe (Zipper String))
    , temptWolf : Int
    }


main : Program Never Model ClientTypes.Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


getIds : List Entity -> List Id
getIds =
    List.map .id


findEntity : Id -> Entity
findEntity id =
    let
        interactables =
            items ++ locations ++ characters

        entity =
            List.head <| List.filter (.id >> (==) id) interactables
    in
        case entity of
            Just entity ->
                entity

            Nothing ->
                Debug.crash <| "Couldn't find entity from id: " ++ id


pluckRules : Engine.Rules
pluckRules =
    let
        foldFn :
            RuleData Engine.Rule
            -> ( Int, Dict String Engine.Rule )
            -> ( Int, Dict String Engine.Rule )
        foldFn { interaction, conditions, changes } ( id, rules ) =
            ( id + 1
            , Dict.insert ((++) "rule" <| toString <| id + 1)
                { interaction = interaction
                , conditions = conditions
                , changes = changes
                }
                rules
            )
    in
        Tuple.second <| List.foldl foldFn ( 1, Dict.empty ) rulesData


pluckContent : Dict String (Maybe (Zipper String))
pluckContent =
    let
        foldFn :
            RuleData Engine.Rule
            -> ( Int, Dict String (Maybe (Zipper String)) )
            -> ( Int, Dict String (Maybe (Zipper String)) )
        foldFn { narrative } ( id, narratives ) =
            ( id + 1
            , Dict.insert ((++) "rule" <| toString <| id + 1)
                (Zipper.fromList narrative)
                narratives
            )
    in
        Tuple.second <| List.foldl foldFn ( 1, Dict.empty ) rulesData


init : ( Model, Cmd ClientTypes.Msg )
init =
    let
        startingState =
            [ moveTo "Cottage"
            , loadScene "start"
            , moveItemToLocation "Cape" "Cottage"
            , moveItemToLocationFixed "Tree" "Woods"
            , moveItemToLocationFixed "Small tree" "Woods"
            , moveItemToLocationFixed "Signpost" "Woods"
            , moveItemToLocationFixed "Bedpost" "Grandma's house"
            , moveCharacterToLocation "Little Red Ridding Hood" "Cottage"
            , moveCharacterToLocation "Mother" "Cottage"
            , moveCharacterToLocation "Wolf" "Woods"
            , moveCharacterToLocation "Grandma" "Grandma's house"
            ]
    in
        ( { engineModel =
                Engine.init
                    { items = getIds items
                    , locations = getIds locations
                    , characters = getIds characters
                    }
                    pluckRules
                    |> Engine.changeWorld startingState
          , loaded = False
          , storyLine =
                [ """
Once upon a time there was a young girl named Little Red Ridding Hood, because she was so fond of her red cape that her grandma gave to her.
"""
                ]
          , content = pluckContent
          , temptWolf = 0
          }
        , Cmd.none
        )


update :
    ClientTypes.Msg
    -> Model
    -> ( Model, Cmd ClientTypes.Msg )
update msg model =
    if Engine.getEnding model.engineModel /= Nothing then
        ( model, Cmd.none )
    else
        case msg of
            Interact interactableId ->
                let
                    ( newEngineModel, maybeMatchedRuleId ) =
                        Engine.update interactableId model.engineModel

                    narrative =
                        getNarrative model.content maybeMatchedRuleId
                            |> Maybe.withDefault (findEntity interactableId |> getDisplay |> .description)

                    updatedContent =
                        maybeMatchedRuleId
                            |> Maybe.map (\id -> Dict.update id updateContent model.content)
                            |> Maybe.withDefault model.content

                    newTemptWolf =
                        case maybeMatchedRuleId of
                            -- "what big eyes you have..." rule
                            Just "rule31" ->
                                model.temptWolf + 1

                            _ ->
                                model.temptWolf

                    checkEnd =
                        if newTemptWolf == 3 then
                            Engine.changeWorld [ endStory "The End", loadScene "bye bye Little Red Ridding Hood" ]
                        else
                            identity
                in
                    ( { model
                        | engineModel = newEngineModel |> checkEnd
                        , storyLine = narrative :: model.storyLine
                        , content = updatedContent
                        , temptWolf = newTemptWolf
                      }
                    , Cmd.none
                    )

            Loaded ->
                ( { model | loaded = True }
                , Cmd.none
                )


port loaded : (Bool -> msg) -> Sub msg


subscriptions : Model -> Sub ClientTypes.Msg
subscriptions model =
    loaded <| always Loaded


getNarrative : Dict String (Maybe (Zipper String)) -> Maybe String -> Maybe String
getNarrative content ruleId =
    ruleId
        |> Maybe.andThen (\id -> Dict.get id content)
        |> Maybe.andThen identity
        |> Maybe.map Zipper.current


updateContent : Maybe (Maybe (Zipper String)) -> Maybe (Maybe (Zipper String))
updateContent =
    let
        nextOrStay narration =
            Zipper.next narration
                |> Maybe.withDefault narration
    in
        (Maybe.map >> Maybe.map) nextOrStay


view :
    Model
    -> Html ClientTypes.Msg
view model =
    let
        currentLocation =
            Engine.getCurrentLocation model.engineModel
                |> findEntity

        displayState =
            { currentLocation = currentLocation
            , itemsInCurrentLocation =
                Engine.getItemsInCurrentLocation model.engineModel
                    |> List.map findEntity
            , charactersInCurrentLocation =
                Engine.getCharactersInCurrentLocation model.engineModel
                    |> List.map findEntity
            , exits =
                getExits currentLocation
                    |> List.map
                        (\( direction, id ) ->
                            ( direction, findEntity id )
                        )
            , itemsInInventory =
                Engine.getItemsInInventory model.engineModel
                    |> List.map findEntity
            , ending =
                Engine.getEnding model.engineModel
            , story =
                List.head model.storyLine |> Maybe.withDefault ""
            , engineModel = model.engineModel
            , temptWolf = model.temptWolf
            }
    in
        if not model.loaded then
            div [ class "loading" ] [ span [] [ text "Loading..." ] ]
        else
            Theme.Layout.view displayState
