{-# LANGUAGE TemplateHaskell #-}
module FloatingAces.Type
  ( module FloatingAces.Type
  ) where
--------------------------------------------------------------------------------
import Prelude
--------------------------------------------------------------------------------
import Control.Lens (makeFieldsNoPrefix)
import Data.UUID    (UUID)
import Data.Default (Default(..))
--------------------------------------------------------------------------------
import qualified Control.Lens as L
import qualified Data.UUID    as UUID
--------------------------------------------------------------------------------
-- Types

type FAResponse = Text

type CardName = Text
type CardID   = UUID

data Card
  = Card
  { _cardName     :: CardName
  , _priorityOver :: HashSet CardID
  } deriving stock (Eq, Show)
makeFieldsNoPrefix ''Card

type ShuffleID     = UUID
type GreaterCardID = CardID
type LesserCardID  = CardID

data GameEvent
  = ShowGame
  | CreateShuffle ShuffleName
  | CreateCard CardName
  | ShuffleCard CardID ShuffleID
  | PriorityOver GreaterCardID LesserCardID
  deriving stock (Eq, Show)

data ShuffleEvent
  = InsertCard CardID
  | SwapCards  CardID CardID
  | DeleteCard CardID
  | PopCard
  | BubbleUp   CardID
  | BubbleDown CardID
  deriving stock (Eq, Show)

type ShuffleName = Text

data Shuffle
  = Shuffle
  { _shuffleName :: ShuffleName
  , _cards       :: Vector CardID
  , _eventQueue  :: Vector ShuffleEvent
  } deriving stock (Eq, Show)
makeFieldsNoPrefix ''Shuffle

type Deck = HashMap CardID Card

data Game
  = Game
  { _deck     :: Deck
  , _shuffles :: HashMap ShuffleID Shuffle
  } deriving stock (Eq, Show)
makeFieldsNoPrefix ''Game

-- | The consistent ID for the universal shuffle
universalShuffleID :: ShuffleID
universalShuffleID = UUID.fromString "00000000-0000-0000-0000-000000000000" ^?! L._Just

-- | Initializea 'Shuffle', given a 'ShuffleName'
initShuffle :: ShuffleName -> Shuffle
initShuffle name
  = Shuffle
  { _shuffleName = name
  , _cards       = mempty
  , _eventQueue  = mempty
  }

-- the universal shuffle exists by default
instance Default Game where
  def = Game
      { _deck     = mempty
      , _shuffles = mapFromList [(universalShuffleID, initShuffle "Universal")]
      }

data FAState = FAState { _game :: Game}
  deriving stock (Eq, Show)
makeFieldsNoPrefix ''FAState

instance Default FAState where
  def = FAState { _game = def}

type FAM = StateT FAState IO
