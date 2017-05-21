port module Main exposing (..)

import Engine exposing (..)
import Manifest exposing (..)
import Rules exposing (rulesData)
import ClientTypes exposing (..)
import Components exposing (..)
import Dict exposing (Dict)
import List.Zipper as Zipper exposing (Zipper)
import Json.Decode exposing (..)


type alias Model =
    { engineModel : Engine.Model
    , content : Dict String (Maybe (Zipper String))
    }


main : Program Never Model ClientTypes.Msg
main =
    Platform.program
        { init = init
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
            , moveItemToLocation "Basket of food" "Cottage"
            , moveCharacterToLocation "Little Red Riding Hood" "Cottage"
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
          , content = pluckContent
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
            Load ->
                let
                    introText =
                        """Once upon a time, there was a young girl named Little Red Ridding Hood, who lived in a cottage with her mother.  """
                in
                    ( model
                    , exportStoryWorld introText model.engineModel
                    )

            Interact interactableId ->
                let
                    ( newEngineModel, maybeMatchedRuleId ) =
                        Engine.update interactableId model.engineModel

                    narrative =
                        getNarrative model.content maybeMatchedRuleId
                            |> Maybe.withDefault ("")

                    updatedContent =
                        maybeMatchedRuleId
                            |> Maybe.map (\id -> Dict.update id updateContent model.content)
                            |> Maybe.withDefault model.content
                in
                    ( { model
                        | engineModel = newEngineModel
                        , content = updatedContent
                      }
                    , exportStoryWorld narrative newEngineModel
                    )


exportStoryWorld : String -> Engine.Model -> Cmd Msg
exportStoryWorld narrative engineModel =
    let
        currentLocation =
            Engine.getCurrentLocation engineModel
    in
        storyWorldUpdate <|
            { currentLocation = currentLocation
            , narrative = narrative
            , interactables =
                Engine.getCharactersInCurrentLocation engineModel
                    ++ Engine.getItemsInCurrentLocation engineModel
                    ++ getExits (findEntity currentLocation)
            }


port load : (Bool -> msg) -> Sub msg


port interact : (String -> msg) -> Sub msg


port storyWorldUpdate : StoryWorld -> Cmd msg


subscriptions : Model -> Sub ClientTypes.Msg
subscriptions model =
    Sub.batch
        [ interact Interact
        , load <| always Load
        ]


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
