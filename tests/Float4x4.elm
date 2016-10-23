module Float4x4 exposing (all)

import Fuzz exposing (..)
import Helper exposing (..)
import Test exposing (..)
import Expect
import Math.Float4x4 as V


all =
    describe "Float4x4"
        [ add, minus, mul, transpose, translate, transform, makeTransform, inverseRigidBodyTransform ]



-- We can't test this library the same way because we can't construct/destruct a Matrix4 by hand


ex1 =
    ( ( 1, 2, 5, 9 )
    , ( 4, 3, 0, 4 )
    , ( 3, -7, 1, -4 )
    , ( 7, -1, 4, 2 )
    )


ex2 =
    ( ( -1, 1, -12, -9 )
    , ( 5, 42, 2, 14 )
    , ( -3, -1, 0, 0 )
    , ( 1, 32, 11, 2 )
    )


add =
    t2 "add" V.add ( ( 0, 3, -7, 0 ), ( 9, 45, 2, 18 ), ( 0, -8, 1, -4 ), ( 8, 31, 15, 4 ) )


minus =
    t2 "minus" V.sub ( ( 2, 1, 17, 18 ), ( -1, -39, -2, -10 ), ( 6, -6, 1, -4 ), ( 6, -33, -7, 0 ) )


mul =
    t2 "mul" V.mul ( ( 3, 368, 91, 37 ), ( 15, 258, 2, 14 ), ( -45, -420, -94, -133 ), ( -22, 25, -64, -73 ) )


transpose =
    t "transpose" V.transpose ( ( 1, 4, 3, 7 ), ( 2, 3, -7, -1 ), ( 5, 0, 1, 4 ), ( 9, 4, -4, 2 ) )


translate =
    test "translate, makeTranslate"
        (\_ ->
            Expect.equal
                (V.translate ( 1, 2, -3 ) V.identity)
                (V.makeTranslate ( 1, 2, -3 ))
        )


transform =
    test "transform"
        (\_ ->
            Expect.equal ( 5, 2, 9 )
                (( 5, 2, 9 )
                    |> V.transform (V.makeTranslate ( -1, -2, 3 ))
                    |> V.transform (V.makeTranslate ( 1, 2, -3 ))
                )
        )


inverseRigidBodyTransform =
    Test.fuzzWith { runs = 20 }
        --fuzz
        m4rigidBody
        "inverseRigidBodyTransform"
        (\m4 ->
            expectAlmostEqualM4 (V.mul (V.inverseRigidBodyTransform m4) m4) (V.identity)
        )


makeTransform =
    Test.fuzzWith { runs = 20 }
        (Fuzz.tuple4 ( v3, v3NonZero, smallFloat, v3NonZero ))
        "makeTransform"
        (\( t, s, r, a ) ->
            expectAlmostEqualM4 (V.makeTransform t s r a ( 0, 0, 0 ))
                (V.mul (V.makeTranslate t) (V.mul (V.makeRotate r a) (V.makeScale s)))
        )


t2 txt op sol =
    test txt (\_ -> Expect.equal (op ex1 ex2) sol)


t txt f sol =
    test txt (\_ -> Expect.equal (f ex1) sol)
