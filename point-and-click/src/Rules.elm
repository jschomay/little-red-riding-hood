module Rules exposing (rulesData)

import Engine exposing (..)
import ClientTypes exposing (..)


rulesData : List (RuleData Engine.Rule)
rulesData =
    { summary = "inspect cape"
    , interaction = with "Cape"
    , conditions =
        [ currentLocationIs "Cottage"
        , hasNotPreviouslyInteractedWith "Mother"
        ]
    , changes =
        []
    , narrative =
        [ """
Little Red Ridding Hood's namesake, her red cape.
"""
        ]
    }
        :: { summary = "mother"
           , interaction = with "Mother"
           , conditions =
                []
           , changes =
                []
           , narrative =
                [ "\"Don't keep Grandma waiting.\""
                , "\"Remember, don't talk to strangers.\""
                , "\"Hurry along Little Red Ridding Hood.\""
                ]
           }
        :: { summary = "Little Red Ridding Hood in Cottage"
           , interaction = with "Little Red Ridding Hood"
           , conditions =
                [ characterIsInLocation "Little Red Ridding Hood" "Cottage" ]
           , changes =
                []
           , narrative =
                [ "Little Red Ridding Hood, who lived with her mother in the cottage near the woods."
                , "Her Grandma gave her a red cape for her 7th birthday, and she's worn it every day since."
                , "Shouldn't you be on your way?"
                , "There's more to see here."
                ]
           }
        :: { summary = "Little Red Ridding Hood in River"
           , interaction = with "Little Red Ridding Hood"
           , conditions =
                [ characterIsInLocation "Little Red Ridding Hood" "River" ]
           , changes =
                []
           , narrative =
                [ "Little Red Ridding Hood loved being outside, although her mother usually forbade her to go past the old bridge."
                , "Little Red Ridding Hood was eager to see her Grandma."
                ]
           }
        :: { summary = "Little Red Ridding Hood in Woods"
           , interaction = with "Little Red Ridding Hood"
           , conditions =
                [ characterIsInLocation "Little Red Ridding Hood" "Woods" ]
           , changes =
                []
           , narrative =
                [ "Little Red Ridding Hood felt slightly afraid in the dark woods."
                , "She seemed very small amongst the tall trees."
                , "She couldn't wait to safely get to her Grandma's house."
                ]
           }
        :: { summary = "Little Red Ridding Hood in Woods2"
           , interaction = with "Little Red Ridding Hood"
           , conditions =
                [ characterIsInLocation "Little Red Ridding Hood" "Woods2" ]
           , changes =
                []
           , narrative =
                [ "At first the wolf startled her, but he seemed so friendly that she soon relaxed."
                , "Grandma's house wasn't far, but it would be rude to ignore the wolf, wouldn't it?"
                ]
           }
        :: { summary = "Little Red Ridding Hood after talking to wolf"
           , interaction = with "Little Red Ridding Hood"
           , conditions =
                [ characterIsInLocation "Little Red Ridding Hood" "Woods2"
                , characterIsInLocation "Wolf" "Grandma's house"
                ]
           , changes =
                []
           , narrative =
                [ "\"That was unusual,\" Little Red Ridding Hood thought to herself.  \"Oh well, I better get to Grandma's.\""
                ]
           }
        :: { summary = "Little Red Ridding Hood in Grandma's House"
           , interaction = with "Little Red Ridding Hood"
           , conditions =
                [ characterIsInLocation "Little Red Ridding Hood" "Grandma's House" ]
           , changes =
                []
           , narrative =
                []
           }
        :: { summary = "Basket of food"
           , interaction = with "Basket of food"
           , conditions =
                []
           , changes =
                [ moveItemToInventory "Basket of food" ]
           , narrative =
                [ "The basket had all kinds of delicious food and cakes and even some wine." ]
           }
        :: { summary = "Cape"
           , interaction = with "Cape"
           , conditions =
                []
           , changes =
                [ moveItemToInventory "Cape" ]
           , narrative =
                [ "Little Red Ridding Hood eagerly put on her red cape." ]
           }
        :: { summary = "mother's instructions"
           , interaction = with "Mother"
           , conditions =
                [ currentLocationIs "Cottage"
                , hasNotPreviouslyInteractedWith "Mother"
                ]
           , changes =
                [ moveItemToLocation "Basket of food" "Cottage" ]
           , narrative =
                [ """
One day, her mother said to her, "Little Red Ridding Hood, take this basket of food to your Grandma, who lives in the woods, because she is not feeling well.  And remember, don't talk to strangers on the way!"
"""
                ]
           }
        :: { summary = "leaving before mother's instructions"
           , interaction = withAnyLocation
           , conditions =
                [ hasNotPreviouslyInteractedWith "Mother"
                , currentLocationIs "Cottage"
                , itemIsNotInInventory "Cape"
                , itemIsNotInInventory "Basket of food"
                ]
           , changes =
                []
           , narrative =
                [ """
The way out of the cottage.
"""
                ]
           }
        :: { summary = "leaving without cape"
           , interaction = withAnyLocation
           , conditions =
                [ currentLocationIs "Cottage"
                , itemIsNotInInventory "Cape"
                ]
           , changes =
                []
           , narrative =
                [ """
"Oh Little Red Ridding Hood," her mother called out, "don't forget your cape.  It might be cold in the woods."
"""
                ]
           }
        :: { summary = "leaving without basket"
           , interaction = withAnyLocation
           , conditions =
                [ currentLocationIs "Cottage"
                , itemIsNotInInventory "Basket of food"
                ]
           , changes =
                []
           , narrative =
                [ """
 "Oh Little Red Ridding Hood," her mother called out, "don't forget the basket of food to bring to Grandma!"
"""
                ]
           }
        :: { summary = "describe cottage"
           , interaction = with "Cottage"
           , conditions =
                [ currentLocationIs "Cottage"
                ]
           , changes =
                []
           , narrative =
                [ """
The cottage where Little Red Ridding Hood and her mother live.
"""
                ]
           }
        :: { summary = "trying to jump directly from Cottage to Grandma's house"
           , interaction = with "Grandma's house"
           , conditions =
                [ currentLocationIs "Cottage"
                , itemIsInInventory "Cape"
                , itemIsInInventory "Basket of food"
                ]
           , changes =
                []
           , narrative =
                [ """
The way to Grandma's house is over the river and through the woods.
"""
                ]
           }
        :: { summary = "trying to jump directly from River to Grandma's house"
           , interaction = with "Grandma's house"
           , conditions =
                [ currentLocationIs "River"
                , itemIsInInventory "Cape"
                , itemIsInInventory "Basket of food"
                ]
           , changes =
                []
           , narrative =
                [ """
The way to Grandma's house is through the woods.
"""
                ]
           }
        :: { summary = "trying to jump directly from Cottage to Woods"
           , interaction = with "Woods"
           , conditions =
                [ currentLocationIs "Cottage"
                , itemIsInInventory "Cape"
                , itemIsInInventory "Basket of food"
                ]
           , changes =
                []
           , narrative =
                [ """
The woods are on the other side of the river.
"""
                ]
           }
        :: { summary = "going back to the Cottage"
           , interaction = with "Cottage"
           , conditions =
                [ currentLocationIsNot "Cottage"
                ]
           , changes =
                []
           , narrative =
                [ """
Little Red Ridding Hood knew that her mother would be cross if she did not bring the basket of food to Grandma.
"""
                ]
           }
        :: { summary = "leaving the Cottage"
           , interaction = with "River"
           , conditions =
                [ currentLocationIs "Cottage"
                , itemIsInInventory "Cape"
                , itemIsInInventory "Basket of food"
                ]
           , changes =
                [ moveTo "River"
                , moveCharacterToLocation "Little Red Ridding Hood" "River"
                ]
           , narrative =
                [ """
Little Red Ridding Hood skipped out of the cottage, singing as she went.  Soon she arrived at the old bridge over the river.  On the other side of the bridge were the woods where Grandma lived.
"""
                ]
           }
        :: { summary = "going from Woods to River"
           , interaction = with "River"
           , conditions =
                [ currentLocationIs "Woods"
                , itemIsInInventory "Cape"
                , itemIsInInventory "Basket of food"
                ]
           , changes =
                []
           , narrative =
                [ """
Grandma's house is the other direction.
"""
                , """
The wolf was still there, trying to hide the hungry look in his eye.
"""
                ]
           }
        :: { summary = "entering the Woods"
           , interaction = with "Woods"
           , conditions =
                [ currentLocationIs "River"
                , itemIsInInventory "Cape"
                , itemIsInInventory "Basket of food"
                , characterIsInLocation "Wolf" "Woods"
                ]
           , changes =
                [ moveTo "Woods"
                , moveCharacterToLocation "Little Red Ridding Hood" "Woods"
                ]
           , narrative =
                [ """
Little Red Ridding Hood made her way over the old bridge and ventured into the dark woods.  At first, she did not notice the wolf, who was watching her from the shadows, licking his lips.
"""
                ]
           }
        :: { summary = "the wolf"
           , interaction = with "Wolf"
           , conditions =
                [ currentLocationIs "Woods"
                , itemIsInInventory "Cape"
                , itemIsInInventory "Basket of food"
                , characterIsInLocation "Wolf" "Woods"
                , hasNotPreviouslyInteractedWith "Wolf"
                ]
           , changes =
                [ moveTo "Woods2"
                , moveCharacterToLocation "Wolf" "Woods2"
                , moveCharacterToLocation "Little Red Ridding Hood" "Woods2"
                ]
           , narrative =
                [ """
The wolf was a crafty wolf, and came up with a plan.  Putting on his best smile, he called out to Little Red Ridding Hood, "Good afternoon little girl!  What a pretty red cape you have!  Tell me, where are you going with that basket of food?"
"""
                ]
           }
        :: { summary = "ignoring the wolf"
           , interaction = with "Grandma's house"
           , conditions =
                [ currentLocationIs "Woods2"
                , itemIsInInventory "Cape"
                , itemIsInInventory "Basket of food"
                , characterIsInLocation "Wolf" "Woods2"
                ]
           , changes =
                [ moveTo "Grandma's house"
                , moveCharacterToLocation "Little Red Ridding Hood" "Grandma's house"
                , endStory "The End"
                ]
           , narrative =
                [ """
Although the wolf seemed very polite, Little Red Ridding Hood remembered her mother's warning about not talking to strangers, and hurried along.

Grandma was so happy to see Little Red Ridding Hood, and together they ate the goodies she had brought, and everyone lived happily ever after.
"""
                ]
           }
        :: { summary = "talking to the wolf in the Woods"
           , interaction = with "Wolf"
           , conditions =
                [ currentLocationIs "Woods2"
                , itemIsInInventory "Cape"
                , itemIsInInventory "Basket of food"
                ]
           , changes =
                [ moveCharacterToLocation "Wolf" "Grandma's house"
                , moveCharacterOffScreen "Grandma"
                ]
           , narrative =
                [ """
The wolf seemed so polite and friendly that she happily replied, "I'm visiting my sick Grandma who lives in these woods, to bring her this basket of food."

Without another word, the wolf smiled and ran off.
"""
                ]
           }
        :: { summary = "finding the wolf at Grandma's house"
           , interaction = with "Grandma's house"
           , conditions =
                [ currentLocationIs "Woods2"
                , characterIsInLocation "Wolf" "Grandma's house"
                ]
           , changes =
                [ moveTo "Grandma's house"
                , moveCharacterToLocation "Little Red Ridding Hood" "Grandma's house"
                ]
           , narrative =
                [ """
Little Red Ridding Hood found the door unlocked, so she went in.  She saw Grandma laying in the bed with the covers pulled high over her face, and her nightcap pulled low over her forehead, but something didn't seem right.
"""
                ]
           }
        :: { summary = "Little Red Ridding Hood demise"
           , interaction = with "Wolf"
           , conditions =
                [ currentLocationIs "Grandma's house" ]
           , changes =
                [ endStory "The End" ]
           , narrative =
                [ """
"Grandma, what big eyes you have."

"The better to see you with, my dear!" Grandma's voice sounded different.
  """
                , """
"And Grandma, what big ears you have."

"The better to hear you with, my dear!" She wasn't sure, but Grandma looked like the wolf from the woods.
  """
                , """
"And Grandma, what big teeth you have!"

"The better to gobble you up with!"  And the wolf jumped out of bed and that is exactly what he did.  And that is why we don't talk to strangers.
  """
                ]
           }
        :: []
