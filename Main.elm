module Main exposing (..)

import Html
import Color exposing (rgb)
import Sketch


lineLen =
    80


backGroundColor =
    Color.hsl (degrees 220) 0.5 0.8


main =
    Sketch.scene backGroundColor
        (Sketch.rectangle
            { width = Sketch.random lineLen (lineLen + 70)
            , height = Sketch.always 30
            , color =
                Sketch.hsla
                    (Sketch.random 200 400)
                    (Sketch.random 0.0 1.0)
                    (Sketch.random 0.8 1.5)
                    (Sketch.random 0.0 0.4)
            }
            |> Sketch.rotate (Sketch.random -0.5 0.5)
        )
