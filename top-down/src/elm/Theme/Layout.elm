module Theme.Layout exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Keyed
import ClientTypes exposing (..)
import Components exposing (..)
import Markdown
import Engine
import Game.TwoD as Game
import Game.TwoD.Camera as Camera
import Game.TwoD.Render as Render exposing (Renderable)
import Game.Resources as Resources exposing (Resources)


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
    , resources : Resources
    , time : Float
    }
    -> Html Msg
view displayState =
    let
        story =
            [ Html.Keyed.node "div" [] [ ( displayState.story, Markdown.toHtml [ class "story" ] displayState.story ) ] ]

        camera =
            Camera.fixedArea (100) ( 0, 0 )

        lrrh =
            let
                rowHeight =
                    0.186

                columnWidth =
                    0.55

                walking row =
                    Render.animatedSprite
                        { texture = Resources.getTexture "img/sprites.png" displayState.resources
                        , position = ( displayState.lrrh.x, displayState.lrrh.y )
                        , size = ( 1, 1 )
                        , bottomLeft = ( 0, rowHeight * row )
                        , topRight = ( columnWidth, rowHeight * (row + 1) )
                        , numberOfFrames = 3
                        , duration = 0.5
                        }

                idle =
                    Render.manuallyManagedAnimatedSpriteWithOptions
                        { texture = Resources.getTexture "img/sprites.png" displayState.resources
                        , position = ( displayState.lrrh.x, displayState.lrrh.y, 0 )
                        , size = ( 1, 1 )
                        , bottomLeft = ( 0, rowHeight * 3 )
                        , topRight = ( columnWidth, rowHeight * 4 )
                        , numberOfFrames = 3
                        , pivot = ( 0, 0 )
                        , rotation = 0
                        , currentFrame = 1
                        }
            in
                if displayState.lrrh.vx > 0 then
                    walking 1
                else if displayState.lrrh.vx < 0 then
                    walking 2
                else if displayState.lrrh.vy > 0 then
                    walking 0
                else if displayState.lrrh.vy < 0 then
                    walking 3
                else
                    idle

        background =
            getSprite displayState.currentLocation |> toRenderable

        sprites =
            displayState.charactersInCurrentLocation |> List.map (getSprite >> toRenderable)

        toRenderable =
            Maybe.map
                (\bg ->
                    Render.animatedSprite
                        { texture = Resources.getTexture bg.texture displayState.resources
                        , position = bg.position
                        , size = bg.size
                        , bottomLeft = bg.bottomLeft
                        , topRight = bg.topRight
                        , numberOfFrames = bg.numberOfFrames
                        , duration = bg.duration
                        }
                )
    in
        div [ class "container" ]
            [ Game.render { time = displayState.time, size = ( 800, 600 ), camera = camera } <|
                List.filterMap identity <|
                    background
                        :: Just lrrh
                        :: sprites
            ]
