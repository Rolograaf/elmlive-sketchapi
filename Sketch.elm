module Sketch
    exposing
        ( scene
        , rectangle
        , rotate
        , random
        , hsla
        , always
        )

import Graphics.Render as Render
import Color exposing (Color)
import Html exposing (Html)
import Html.App
import Random
import Time


type Shape
    = Rectangle
        { width : SketchNumber
        , height : SketchNumber
        , color : SketchColor
        }
    | Rotate SketchNumber Shape


type SketchNumber
    = ConstantNumber Float
    | RandomNumber { min : Float, max : Float }


type SketchColor
    = SketchColor
        { hue : SketchNumber
        , saturation : SketchNumber
        , lightness : SketchNumber
        , alpha : SketchNumber
        }


type alias SceneState =
    { seed : Random.Seed }


type SceneMsg
    = NewRandomSeed


scene : Color -> Shape -> Program Never
scene backGroundColor shape =
    let
        sceneSize =
            { width = 500, height = 500 }

        initialModel : SceneState
        initialModel =
            { seed = Random.initialSeed 0 }

        update msg model =
            case msg of
                NewRandomSeed ->
                    let
                        ( _, newSeed ) =
                            renderScene sceneSize backGroundColor shape model.seed
                    in
                        ( { model | seed = newSeed }, Cmd.none )

        view model =
            let
                ( html, _ ) =
                    renderScene sceneSize backGroundColor shape model.seed
            in
                html
    in
        Html.App.program
            { init = ( initialModel, Cmd.none )
            , subscriptions = \_ -> Time.every 100 (Basics.always NewRandomSeed)
            , update = update
            , view = view
            }


renderScene :
    { width : Float, height : Float }
    -> Color
    -> Shape
    -> Random.Seed
    -> ( Html msg, Random.Seed )
renderScene sceneSize backGroundColor shape seed =
    let
        ( shapeValue, seed1 ) =
            renderShape shape seed
    in
        ( Render.group
            [ Render.rectangle sceneSize.width sceneSize.height
                |> Render.solidFill backGroundColor
            , shapeValue
            ]
            |> Render.svg sceneSize.width sceneSize.height
        , seed1
        )


renderShape : Shape -> Random.Seed -> ( Render.Form msg, Random.Seed )
renderShape shape seed =
    case shape of
        Rectangle { width, height, color } ->
            let
                ( widthValue, seed1 ) =
                    toFloat width seed

                ( heightValue, seed2 ) =
                    toFloat height seed1

                ( colorValue, seed3 ) =
                    toColor color seed2
            in
                ( Render.rectangle widthValue heightValue
                    |> Render.solidFill colorValue
                , seed3
                )

        Rotate angle innerShape ->
            let
                ( angelValue, seed1 ) =
                    toFloat angle seed

                ( innerShapeValue, seed2 ) =
                    renderShape innerShape seed1
            in
                ( Render.rotate angelValue innerShapeValue
                , seed2
                )



-- SHAPES


rectangle :
    { width : SketchNumber
    , height : SketchNumber
    , color : SketchColor
    }
    -> Shape
rectangle =
    Rectangle


rotate : SketchNumber -> Shape -> Shape
rotate angle shape =
    Rotate angle shape



-- VALUES


random : Float -> Float -> SketchNumber
random min max =
    RandomNumber { min = min, max = max }


always : Float -> SketchNumber
always value =
    ConstantNumber value


toFloat : SketchNumber -> Random.Seed -> ( Float, Random.Seed )
toFloat number seed =
    case number of
        ConstantNumber value ->
            ( value, seed )

        RandomNumber { min, max } ->
            Random.step (Random.float min max) seed


hsla :
    SketchNumber
    -> SketchNumber
    -> SketchNumber
    -> SketchNumber
    -> SketchColor
hsla hue saturation lightness alpha =
    SketchColor
        { hue = hue
        , saturation = saturation
        , lightness = lightness
        , alpha = alpha
        }


toColor : SketchColor -> Random.Seed -> ( Color, Random.Seed )
toColor color seed =
    case color of
        SketchColor { hue, saturation, lightness, alpha } ->
            let
                ( hueValue, seed1 ) =
                    toFloat hue seed

                ( saturationValue, seed2 ) =
                    toFloat saturation seed1

                ( lightnessValue, seed3 ) =
                    toFloat lightness seed2

                ( alphaValue, seed4 ) =
                    toFloat alpha seed3
            in
                ( Color.hsla
                    (degrees <| hueValue)
                    saturationValue
                    lightnessValue
                    alphaValue
                , seed4
                )
