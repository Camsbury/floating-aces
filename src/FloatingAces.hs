module FloatingAces
  ( module FloatingAces
  , module FloatingAces.Type
  ) where
--------------------------------------------------------------------------------
import Prelude
--------------------------------------------------------------------------------
import FloatingAces.Type
--------------------------------------------------------------------------------
import Data.Default (Default(..))
--------------------------------------------------------------------------------
import qualified Control.Lens as L
import qualified Data.UUID.V4 as UUID
import qualified FloatingAces.Parse  as P
import qualified FloatingAces.Render as R
--------------------------------------------------------------------------------
-- | The entry point for the application
runFA :: Text -> FAM FAResponse
runFA request
  = either (pure . mappend "Invalid Request: " . pack) handleGameEvent
  $ P.parseEvent request

--------------------------------------------------------------------------------
-- Game Event Handling

-- | Handles events for the 'Game'
handleGameEvent :: GameEvent -> FAM FAResponse
handleGameEvent ShowGame = pure . R.renderOrg =<< L.use game
handleGameEvent (CreateShuffle shuffleName) = do -- TODO: check the name doesn't already exist
  shuffleID <- liftIO $ UUID.nextRandom
  game . shuffles . L.at shuffleID ?= Shuffle shuffleName mempty mempty
  showGame
handleGameEvent (CreateCard cardName) = do -- TODO: check the name doesn't already exist
  cardID <- liftIO $ UUID.nextRandom
  game . deck . L.at cardID ?= Card cardName mempty
  handleGameEvent (ShuffleCard cardID universalShuffleID)
handleGameEvent (ShuffleCard cardID shuffleID) = do
  enqueueShuffleEvent (InsertCard cardID) shuffleID
  -- enqueueShuffleEvent (BubbleUp   cardID) shuffleID -- FIXME: implement bubble up
  nextShuffleEvent shuffleID
  showGame
handleGameEvent (PriorityOver greaterCardID lesserCardID) = do
  game . deck . L.ix greaterCardID . priorityOver %= insertSet lesserCardID
  showGame

-- | Shows the current 'Game'
showGame :: FAM FAResponse
showGame = do
  pure . R.renderOrg =<< L.use game


--------------------------------------------------------------------------------
-- Shuffle Event Handling

-- | Enqueue an event for a given 'Shuffle'
enqueueShuffleEvent :: ShuffleEvent -> ShuffleID -> FAM ()
enqueueShuffleEvent event ident
  = game . shuffles . L.ix ident . eventQueue %= (`snoc` event)

-- | Next Event in a 'Shuffle''s queue
nextShuffleEvent :: ShuffleID -> FAM ()
nextShuffleEvent ident = do
  events <- gets . L.view
    $ game . shuffles . L.ix ident . eventQueue
  nextShuffleEvent' events
  where
    nextShuffleEvent' :: Vector ShuffleEvent -> FAM ()
    nextShuffleEvent' [] = pure ()
    nextShuffleEvent' (e L.:< es) = do
      game . shuffles . L.ix ident . eventQueue .= es
      handleShuffleEvent e ident

-- | Restores a 'ShuffleEvent' to the queue
restoreShuffleEvent :: ShuffleEvent -> ShuffleID -> FAM ()
restoreShuffleEvent event shuffleID = undefined

-- | Handles events for a given 'Shuffle'
handleShuffleEvent :: ShuffleEvent -> ShuffleID -> FAM ()
handleShuffleEvent (InsertCard cardID) shuffleID = do
  game . shuffles . L.ix shuffleID . cards %= (`snoc` cardID)
handleShuffleEvent (BubbleUp cardID) shuffleID = do
  cardHeap <- gets . L.view $ game . shuffles . L.ix shuffleID . cards
  -- find the parent
  -- find their priorityOver sets
  -- if the parent is lower priority, restore this to queue plus a swap event
  -- if the parent is higher priority, pure ()
  -- if unknown, push back onto queue
  pure ()
