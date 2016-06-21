module Test.NavigationTests exposing (..)

import ElmTest exposing (..)
import MultiwayTree exposing (Tree(..))
import MultiwayTreeZipper exposing (..)
import Test.SampleData exposing (singleChildTree, multiChildTree, deepTree, noChildTree, interestingTree)


(&>) =
    Maybe.andThen


tests : Test
tests =
    suite "Navigation"
        [ test "Navigate to child (only child)"
            <| assertEqual (Just ( (Tree "b" []), [ Context "a" [] [] ] ))
                (Just ( singleChildTree, [] )
                    &> goToChild 0
                )
        , test "Navigate to child (one of many)"
            <| assertEqual
                (Just
                    ( (Tree "c" [])
                    , [ Context "a"
                            [ (Tree "b" []) ]
                            [ (Tree "d" []) ]
                      ]
                    )
                )
                (Just ( multiChildTree, [] )
                    &> goToChild 1
                )
        , test "Navigate to a child (deep)"
            <| assertEqual
                (Just
                    ( (Tree "d" [])
                    , [ Context "c" [] []
                      , Context "b" [] []
                      , Context "a" [] []
                      ]
                    )
                )
                (Just ( deepTree, [] )
                    &> goToChild 0
                    &> goToChild 0
                    &> goToChild 0
                )
        , test "Navigate up (single level)"
            <| assertEqual (Just ( (Tree "a" [ Tree "b" [] ]), [] ))
                (Just ( singleChildTree, [] )
                    &> goToChild 0
                    &> goUp
                )
        , test "Navigate up (single level with many children)"
            <| assertEqual (Just ( (Tree "a" [ Tree "b" [], Tree "c" [], Tree "d" [] ]), [] ))
                (Just ( multiChildTree, [] )
                    &> goToChild 1
                    &> goUp
                )
        , test "Navigate up from a child (deep)"
            <| assertEqual (Just ( (Tree "a" [ Tree "b" [ Tree "c" [ Tree "d" [] ] ] ]), [] ))
                (Just ( deepTree, [] )
                    &> goToChild 0
                    &> goToChild 0
                    &> goToChild 0
                    &> goUp
                    &> goUp
                    &> goUp
                )
        , test "Navigate beyond the tree (only child)"
            <| assertEqual Nothing
                (Just ( singleChildTree, [] )
                    &> goToChild 0
                    &> goToChild 0
                )
        , test "Navigate beyond the tree (up past root)"
            <| assertEqual Nothing
                (Just ( singleChildTree, [] )
                    &> goUp
                )
        , test "Navigate to right sibling on no child tree does not work"
            <| assertEqual Nothing
                (Just ( noChildTree, [] )
                    &> goRight
                )
        , test "Navigate to right child"
            <| assertEqual
                (Just
                    ( (Tree "c" [])
                    , [ Context "a"
                            [ (Tree "b" []) ]
                            [ (Tree "d" []) ]
                      ]
                    )
                )
                (Just ( multiChildTree, [] )
                    &> goToChild 0
                    &> goRight
                )
        , test "Navigate to right child twice"
            <| assertEqual
                (Just ( multiChildTree, [] )
                    &> goToChild 2
                )
                (Just ( multiChildTree, [] )
                    &> goToChild 0
                    &> goRight
                    &> goRight
                )
        , test "Navigate to right child when there are no siblings left return Nothing"
            <| assertEqual Nothing
                (Just ( multiChildTree, [] )
                    &> goToChild 2
                    &> goRight
                )
        , test "Navigate to next child on Tree with just one node"
            <| assertEqual (Just ( noChildTree, [] ))
                (Just ( noChildTree, [] )
                    &> goToNext
                )
        , test "Navigate to next child on an interesting tree will select the next node"
            <| assertEqual
                (Just ( interestingTree, [] )
                    &> goToChild 0
                    &> goToChild 0
                )
                (Just ( interestingTree, [] )
                    &> goToChild 0
                    &> goToNext
                )
        , test "Navigate to next child when the end of a branch has been reached will perform backtracking until the next node down can be reached"
            <| assertEqual
                (Just ( interestingTree, [] )
                    &> goToChild 1
                )
                (Just ( interestingTree, [] )
                    &> goToChild 0
                    &> goToChild 0
                    &> goToChild 0
                    &> goToNext
                )
        , test "Navigating to the end of a Tree will keep the last node selected"
            <| assertEqual
                (Just ( deepTree, [] )
                    &> goToChild 0
                    &> goToChild 0
                    &> goToChild 0
                )
                (Just ( deepTree, [] )
                    &> goToNext
                    &> goToNext
                    &> goToNext
                )
        , test "Consecutive goToNext on an interestingTree end up on the right Node"
            <| assertEqual
                (Just ( interestingTree, [] )
                    &> goToChild 2
                    &> goToChild 1
                )
                (Just ( interestingTree, [] )
                    &> goToNext
                    &> goToNext
                    &> goToNext
                    &> goToNext
                    &> goToNext
                    &> goToNext
                    &> goToNext
                    &> goToNext
                    &> goToNext
                )
        ]
