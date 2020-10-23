{-# LANGUAGE TemplateHaskell #-}
module FloatingAces.Type
  ( module FloatingAces.Type
  ) where
--------------------------------------------------------------------------------
import Prelude
--------------------------------------------------------------------------------
import Control.Lens (makeFieldsNoPrefix)
import Data.UUID (UUID)
import Data.Default (Default(..))
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Types

type FAResponse  = Text
type CardName    = Text
type CardID      = UUID
type Shuffle     = Vector CardID
type ShuffleName = Text

data Card
  = Card
  { _cardName :: CardName
  , _priorityOver :: HashSet CardID
  } deriving stock (Eq, Show)
makeFieldsNoPrefix ''Card

type Deck = HashMap CardID Card

data FAComparisonRequest
  = FAComparisonRequest CardID CardID
  deriving stock (Eq, Show)

type GreaterCardID = CardID
type LesserCardID  = CardID
data FAEvent -- split into internal and external events
  = ShowDeck
  | CreateShuffle ShuffleName
  | CreateCard CardName
  | ShuffleCard CardID ShuffleName
  | PriorityOver GreaterCardID LesserCardID
  deriving stock (Eq, Show)

data Game
  = Game
  { _deck :: Deck
  , _shuffles :: HashMap ShuffleName Shuffle
  } deriving stock (Eq, Show)
makeFieldsNoPrefix ''Game

instance Default Game where
  def = Game
      { _deck     = mempty
      , _shuffles = mapFromList [("Universal", mempty)]
      }

data FAState
  = FAState
  { _game       :: Game
  , _eventQueue :: Vector FAEvent
  , _comparisonQueue :: Vector FAComparisonRequest
  } deriving stock (Eq, Show)
makeFieldsNoPrefix ''FAState

instance Default FAState where
  def = FAState
      { _game       = def
      , _eventQueue = mempty
      , _comparisonQueue = mempty
      }

type FAM = StateT FAState IO
