{-# LANGUAGE TemplateHaskell #-}
module FloatingAces.Type
  ( module FloatingAces.Type
  ) where
--------------------------------------------------------------------------------
import Prelude
--------------------------------------------------------------------------------
import Control.Lens.Operators
import Control.Monad.State
--------------------------------------------------------------------------------
import Control.Lens (makeFieldsNoPrefix)
import Data.UUID (UUID)
--------------------------------------------------------------------------------
-- Types

type FAResponse = Text
type CardName   = Text
type Card       = Text
type Deck       = HashMap UUID Card
type Shuffle    = Vector UUID

data FAEvent
  = ShowDeck
  | CreateCard CardName
  deriving stock (Eq, Show)

data Game
  = Game
  { _deck :: Deck
  , _shuffles :: HashMap Text Shuffle
  } deriving stock (Eq, Show)
makeFieldsNoPrefix ''Game

data FAState
  = FAState
  { _game       :: Game
  , _eventQueue :: [FAEvent]
  } deriving stock (Eq, Show)
makeFieldsNoPrefix ''FAState

-- TODO: update all these to just be Default instances...
initShuffle :: HashMap Text Shuffle
initShuffle = mapFromList [("Universal", [])]

initGame :: Game
initGame
  = Game
  { _deck     = mempty
  , _shuffles = initShuffle
  }

initState :: FAState
initState
  = FAState
  { _game       = initGame
  , _eventQueue = mempty
  }

type FAM = StateT FAState IO
