port module Main exposing (..)

import Engine exposing (..)
import Manifest exposing (..)
import Rules exposing (rulesData)
import ClientTypes exposing (..)
import Components exposing (..)
import Dict exposing (Dict)
import List.Zipper as Zipper exposing (Zipper)
import Keyboard.Extra exposing (Key)
import AnimationFrame
import Game.Resources as Resources exposing (Resources)


type alias Model =
    { engineModel : Engine.Model
    , loaded : Bool
    , storyLine : List String
    , content : Dict String (Maybe (Zipper String))
    , time : Float
    , keys : List Key
    , lrrh : LRRH
    , resources : Resources
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
          , loaded = False
          , storyLine =
                [ """
Once upon a time there was a young girl named Little Red Riding Hood, because she was so fond of her red cape that her grandma gave to her.

One day, her mother said to her, "Little Red Riding Hood, take this basket of food to your Grandma, who lives in the woods, because she is not feeling well.  And remember, don't talk to strangers on the way!"
"""
                ]
          , content = pluckContent
          , time = 0
          , keys = []
          , lrrh = LRRH 0 0 0 0
          , resources = Resources.init
          }
        , Cmd.map Resources <|
            Resources.loadTextures
                [ "img/sprites.png"
                , "img/cottage.png"
                ]
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
                in
                    ( { model
                        | engineModel = newEngineModel
                        , storyLine = narrative :: model.storyLine
                        , content = updatedContent
                      }
                    , Cmd.none
                    )

            Loaded ->
                ( { model | loaded = True }
                , Cmd.none
                )

            Tick dt ->
                ( { model
                    | time = model.time + dt
                    , lrrh = tick dt model.keys model.lrrh
                  }
                , Cmd.none
                )

            Resources msg ->
                ( { model | resources = Resources.update msg model.resources }
                , Cmd.none
                )

            Keys keyMsg ->
                ( { model | keys = Keyboard.Extra.update keyMsg model.keys }
                , Cmd.none
                )


tick : Float -> List Key -> LRRH -> LRRH
tick dt keys lrrh =
    let
        lrrhSpeed =
            2.2

        toUnitVector { x, y } =
            if abs x == abs y then
                { x = toFloat x / (sqrt 2), y = toFloat y / (sqrt 2) }
            else
                { x = toFloat x, y = toFloat y }

        multiplyVector scalar { x, y } =
            { x = x * scalar, y = y * scalar }

        updateSpeed lrrh =
            Keyboard.Extra.arrows keys
                |> toUnitVector
                |> multiplyVector lrrhSpeed
                |> \{ x, y } -> { lrrh | vx = x, vy = y }

        updatePosition lrrh =
            { lrrh
                | x = lrrh.x + dt * lrrh.vx
                , y = lrrh.y + dt * lrrh.vy
            }
    in
        lrrh
            |> updateSpeed
            |> updatePosition


port loaded : (Bool -> msg) -> Sub msg


subscriptions : Model -> Sub ClientTypes.Msg
subscriptions model =
    Sub.batch
        [ loaded <| always Loaded
        , Sub.map Keys Keyboard.Extra.subscriptions
        , AnimationFrame.diffs ((\dt -> dt / 1000) >> Tick)
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
