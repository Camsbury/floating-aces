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
import Data.Default (Default(..))
--------------------------------------------------------------------------------
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

instance Default Game where
  def = Game
      { _deck     = mempty
      , _shuffles = mapFromList [("Universal", mempty)]
      }

data FAState
  = FAState
  { _game       :: Game
  , _eventQueue :: Vector FAEvent
  } deriving stock (Eq, Show)
makeFieldsNoPrefix ''FAState

instance Default FAState where
  def = FAState
      { _game       = def
      , _eventQueue = mempty
      }

type FAM = StateT FAState IO
