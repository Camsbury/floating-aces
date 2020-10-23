module FloatingAces
  ( module FloatingAces
  , module FloatingAces.Type
  ) where
--------------------------------------------------------------------------------
import Prelude
--------------------------------------------------------------------------------
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
enqueueableEvent ShowDeck           = False
enqueueableEvent (CreateShuffle _)  = False
enqueueableEvent (CreateCard _)     = True
enqueueableEvent (ShuffleCard _ _)  = True
enqueueableEvent (PriorityOver _ _) = False

-- | Handles a new event from the client
-- NOTE: may be a better way than 'bool'
handleNewEvent :: FAEvent -> FAM FAResponse
handleNewEvent event
  = bool (handleEvent event) (enqueueEvent event >> handleNextEvent)
  $ enqueueableEvent event

-- | Sticks the event in the queue
enqueueEvent :: FAEvent -> FAM ()
enqueueEvent event = do
  eventQueue %= (`snoc` event)

-- | Handles the next event in the queue
handleNextEvent :: FAM FAResponse
handleNextEvent
  = handleEvent' =<< L.use eventQueue
  where
    handleEvent' :: Vector FAEvent -> FAM FAResponse
    handleEvent' [] = showDeck
    handleEvent' (e L.:< es) = do
      eventQueue .= es
      handleEvent e


--------------------------------------------------------------------------------
-- Event Handling

-- FIXME: this is currently broken... if the event fails it will just move on
-- really need event queues and such per shuffle, not game
-- | Handles enqueued events
handleEvent :: FAEvent -> FAM FAResponse
handleEvent ShowDeck = showDeck
handleEvent (CreateShuffle shuffleName) = do
  shuffle <- gets . L.view $ game . shuffles . L.at shuffleName
  case shuffle of
    (Just _) -> pure ()
    Nothing  -> game . shuffles . L.at shuffleName ?= mempty
  handleNextEvent
handleEvent (CreateCard cardName) = do
  cardID <- liftIO $ UUID.nextRandom
  game . deck . L.at cardID ?= Card cardName mempty
  enqueueEvent (ShuffleCard cardID "Universal")
  handleNextEvent
handleEvent (ShuffleCard cardID shuffleName) = do
  game . shuffles . L.ix shuffleName %= cons cardID
  -- TODO: (BubbleUp cardID shuffleName) as internal event
  handleNextEvent
handleEvent (PriorityOver greaterCardID lesserCardID) = do
  game . deck . L.ix greaterCardID . priorityOver %= insertSet lesserCardID
  handleNextEvent

-- | Shows the current 'Deck'
-- TODO: create renderers for each subset of 'Game',
-- then just render the game as the default response
showDeck :: FAM FAResponse
showDeck = do
  cards <- gets $ L.toListOf (game . deck . L.folded . cardName)
  pure
    . mappend "* cards\n"
    . intercalate "\n"
    . fmap ("** " <>)
    $ cards
