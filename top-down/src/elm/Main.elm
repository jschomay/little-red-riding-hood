port module Main exposing (..)

import Engine exposing (..)
import Manifest exposing (..)
import Rules exposing (rulesData)
import ClientTypes exposing (..)
import Dict exposing (Dict)
import List.Zipper as Zipper exposing (Zipper)
import Json.Decode exposing (..)


type alias Model =
    { engineModel : Engine.Model
    , storyLine : List String
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
            , loadScene "start"
            , moveItemToLocation "Cape" "Cottage"
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
          , storyLine =
                [ """
Once upon a time there was a young girl named Little Red Riding Hood, because she was so fond of her red cape that her grandma gave to her.

One day, her mother said to her, "Little Red Riding Hood, take this basket of food to your Grandma, who lives in the woods, because she is not feeling well.  And remember, don't talk to strangers on the way!"
"""
                ]
          , content = pluckContent
          }
        , fromElm "hi from elm"
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
            FromJS string ->
                let
                    x =
                        Debug.log "from js" string
                in
                    ( model, Cmd.none )

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
                        , storyLine = narrative :: model.storyLine
                        , content = updatedContent
                      }
                    , Cmd.none
                    )


port toElm : (String -> msg) -> Sub msg


port fromElm : String -> Cmd msg


subscriptions : Model -> Sub ClientTypes.Msg
subscriptions model =
    Sub.batch
        [ toElm FromJS ]


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
