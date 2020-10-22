module FloatingAces
  ( module FloatingAces
  , module FloatingAces.Type
  ) where
--------------------------------------------------------------------------------
import Prelude
--------------------------------------------------------------------------------
import Control.Lens.Operators
import Control.Monad.State
import FloatingAces.Type
--------------------------------------------------------------------------------
import qualified Control.Lens as L
import qualified Data.UUID.V4 as UUID
import qualified FloatingAces.Parser as P
--------------------------------------------------------------------------------
-- | The entry point for the application
runFA :: Text -> FAM FAResponse
runFA request
  = either (pure . mappend "Invalid Request: " . pack) handleNewEvent
  $ P.parseEvent request


--------------------------------------------------------------------------------
-- Event Queueing

-- | Should this event be enqueued?
enqueueableEvent :: FAEvent -> Bool
enqueueableEvent (CreateCard _) = True
enqueueableEvent ShowDeck = False

-- | Handles a new event from the client
-- NOTE: may be a better way than 'bool'
handleNewEvent :: FAEvent -> FAM FAResponse
handleNewEvent event
  = bool (handleEvent event) (enqueueEvent event)
  $ enqueueableEvent event

-- | Sticks the event in the queue
enqueueEvent :: FAEvent -> FAM FAResponse
enqueueEvent event = do
  eventQueue %= (`snoc` event)
  handleNextEvent

-- | Handles the next event in the queue
handleNextEvent :: FAM FAResponse
handleNextEvent
  = maybe showDeck handleEvent
  . headMay
  =<< L.use eventQueue


--------------------------------------------------------------------------------
-- Event Handling

-- | Handles enqueued events
handleEvent :: FAEvent -> FAM FAResponse
handleEvent (CreateCard cardName) = do
  cardID <- liftIO $ UUID.nextRandom
  game . deck . L.at cardID ?= cardName
  -- TODO: shuffle the card in via another event
  -- use xndr for inspo
  game . shuffles . L.ix "Universal" %= cons cardID
  handleNextEvent
handleEvent ShowDeck = showDeck

-- | Shows the current 'Deck'
-- TODO: create renderers for each subset of 'Game',
-- then just render the game as the default response
showDeck :: FAM FAResponse
showDeck = do
  cards <- gets $ L.toListOf (game . deck . L.folded)
  pure
    . mappend "* cards\n"
    . intercalate "\n"
    . fmap ("** " <>)
    $ cards
