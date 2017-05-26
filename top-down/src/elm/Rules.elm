module Rules exposing (rulesData)

import Engine exposing (..)
import ClientTypes exposing (..)


rulesData : List (RuleData Engine.Rule)
rulesData =
    { summary = "leaving before instructions"
    , interaction = withAnyLocation
    , conditions =
        [ currentLocationIs "Cottage"
        , hasNotPreviouslyInteractedWith "Mother"
        , itemIsNotInInventory "Basket of food"
        ]
    , changes =
        []
    , narrative =
        [ """Mother: "Little Red Ridding Hood!  Please come here here, I have something to tell you."
"""
        ]
    }
        :: { summary = "looking at basket before instructions"
           , interaction = with "Basket of food"
           , conditions =
                [ hasNotPreviouslyInteractedWith "Mother"
                ]
           , changes =
                []
           , narrative =
                [ """A yummy looking basket of food.
"""
                ]
           }
        :: { summary = "instructions from mother"
           , interaction = with "Mother"
           , conditions =
                [ currentLocationIs "Cottage"
                , itemIsNotInInventory "Basket of food"
                ]
           , changes =
                []
           , narrative =
                [ """Mother: "I want you to take this basket of food to your Grandma, because she isn't feeling well.  But remember, don't talk to strangers on the way!"
"""
                ]
           }
        :: { summary = "mother hurries you along"
           , interaction = with "Mother"
           , conditions =
                [ currentLocationIs "Cottage"
                , itemIsInInventory "Basket of food"
                ]
           , changes =
                []
           , narrative =
                [ """Mother: "What are you waiting for?  Get a move on!"
"""
                ]
           }
        :: { summary = "leaving without basket"
           , interaction = withAnyLocation
           , conditions =
                [ currentLocationIs "Cottage"
                , hasPreviouslyInteractedWith "Mother"
                , itemIsNotInInventory "Basket of food"
                ]
           , changes =
                []
           , narrative =
                [ """Mother: "Oh Little Red Riding Hood, don't forget the basket of food to bring to Grandma!"
"""
                ]
           }
        :: { summary = "taking the basket of food"
           , interaction = with "Basket of food"
           , conditions =
                [ currentLocationIs "Cottage"
                , hasPreviouslyInteractedWith "Mother"
                ]
           , changes =
                [ moveItemToInventory "Basket of food" ]
           , narrative =
                [ """Little Red Ridding Hood enjoyed visiting her Grandma, and looked forward to seeing her again.
"""
                ]
           }
        :: { summary = "leaving cottage"
           , interaction = with "Woods"
           , conditions =
                [ currentLocationIs "Cottage"
                , itemIsInInventory "Basket of food"
                ]
           , changes =
                [ moveTo "Woods"
                , moveCharacterToLocation "Little Red Ridding Hood" "Woods"
                ]
           , narrative =
                [ """It was a beautiful day and Little Red Ridding Hood skipped through the grassy meadow on her way to Grandma's house.
"""
                ]
           }
        :: { summary = "going back to the Cottage"
           , interaction = with "Cottage"
           , conditions =
                []
           , changes =
                []
           , narrative =
                [ """Little Red Riding Hood knew that her mother would be cross if she did not bring the basket of food to Grandma.
"""
                ]
           }
        :: { summary = "crossing the bridge"
           , interaction = with "Bridge"
           , conditions =
                []
           , changes =
                []
           , narrative =
                [ """The old bridge separated the cottage from the woods.  Usually, Little Red Ridding Hood's mother forbade her from going across it.
"""
                ]
           }
        :: { summary = "entering forest"
           , interaction = with "Forest"
           , conditions =
                []
           , changes =
                []
           , narrative =
                [ """The forest was dark and Little Red Ridding Hood felt a little afraid, but continued on bravely.
"""
                ]
           }
        :: { summary = "see wolf"
           , interaction = with "Wolf den"
           , conditions =
                [ hasNotPreviouslyInteractedWith "Wolf" ]
           , changes =
                []
           , narrative =
                [ """At first she didn't notice the wolf hiding in the trees.
Wolf: "Hello little girl.  Won't you come here and tell me where you are going?"
"""
                ]
           }
        :: { summary = "talking to wolf"
           , interaction = with "Wolf"
           , conditions =
                []
           , changes =
                []
           , narrative =
                [ """Little Red Ridding Hood: "I'm visiting my Grandma who lives in these woods."
Wolf: "I see...  How touching.  Better not keep Granny waiting."
"""
                ]
           }
        :: { summary = "leaving wolf"
           , interaction = with "Wolf den"
           , conditions =
                [ hasPreviouslyInteractedWith "Wolf"
                , characterIsInLocation "Wolf" "Woods"
                ]
           , changes =
                [ moveCharacterToLocation "Wolf" "Grandma's house"
                , moveItemToLocationFixed "Ears" "Grandma's house"
                , moveItemToLocationFixed "Teeth" "Grandma's house"
                , moveCharacterOffScreen "Grandma"
                ]
           , narrative =
                [ """Only then did Little Red Ridding Hood remember her mother's warning about not talking to strangers.  That couldn't have done any harm, could it?
"""
                ]
           }
        :: { summary = "return to wolf"
           , interaction = with "Wolf den"
           , conditions =
                [ characterIsInLocation "Wolf" "Grandma's house" ]
           , changes =
                []
           , narrative =
                [ """Where did the wolf go?
"""
                ]
           }
        :: { summary = "grandma's house after talking to wolf"
           , interaction = with "Grandma's house"
           , conditions =
                [ characterIsInLocation "Wolf" "Grandma's house" ]
           , changes =
                [ moveTo "Grandma's house"
                , moveCharacterToLocation "Little Red Ridding Hood" "Grandma's house"
                ]
           , narrative =
                [ """Something seemed different about Grandma.
Little Red Ridding Hood: "Grandma, what big eyes you have."
Wolf: "The better to see you with."
"""
                ]
           }
        :: { summary = "what big ears you have"
           , interaction = with "Ears"
           , conditions =
                [ characterIsInLocation "Wolf" "Grandma's house" ]
           , changes =
                [ moveItemOffScreen "Ears" ]
           , narrative =
                [ """Little Red Ridding Hood: "And Grandma, what big ears you have."
Wolf: "The better to hear you with my dear."
"""
                ]
           }
        :: { summary = "what big teeth"
           , interaction = with "Teeth"
           , conditions =
                [ characterIsInLocation "Wolf" "Grandma's house" ]
           , changes =
                [ moveItemOffScreen "Teeth"
                , endStory "Sad"
                ]
           , narrative =
                [ """Little Red Ridding Hood: "And Grandma, what big teeth you have!"
Wolf: "The better to gobble you up with!"
And that is exactly what he did.
"""
                ]
           }
        :: { summary = "wolf in grandmas house"
           , interaction = with "Wolf"
           , conditions =
                [ currentLocationIs "Grandma's house"
                ]
           , changes =
                []
           , narrative =
                []
           }
        :: { summary = "grandma's house"
           , interaction = with "Grandma's house"
           , conditions =
                [ characterIsInLocation "Grandma" "Grandma's house" ]
           , changes =
                [ moveTo "Grandma's house"
                , moveCharacterToLocation "Little Red Ridding Hood" "Grandma's house"
                , endStory "happy"
                ]
           , narrative =
                [ """Little Red Ridding Hood arrived safely at Grandma's house.  Grandma was happy to see her, and they ate all the food.
"""
                ]
           }
        :: []
