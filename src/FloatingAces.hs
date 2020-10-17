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
import qualified Data.Attoparsec.Text as AP
import qualified Data.Char as C
import qualified Data.UUID.V4 as UUID
--------------------------------------------------------------------------------
import Control.Lens
  ( at
  , ix
  , folded
  , use
  )
import Data.Attoparsec.Text (Parser)
import Data.UUID (UUID)
import FloatingAces.Parser (parseEvent)
--------------------------------------------------------------------------------

-- | The entry point for the application
runFA :: Text -> FAM FAResponse
runFA request
  = either (pure . mappend "Invalid Request: " . pack) handleEvent
  $ parseEvent request

-- | Handles parsed events
handleEvent :: FAEvent -> FAM FAResponse
handleEvent (CreateCard cardName) = do
  cardID <- liftIO $ UUID.nextRandom
  game . deck . at cardID ?= cardName
  -- TODO: shuffle the card in via another event
  -- use xndr for inspo
  game . shuffles . ix "Universal" %= cons cardID
  logState
  showDeck
handleEvent ShowDeck = logState >> showDeck

-- | Logs the current state
logState :: FAM ()
logState = liftIO . print =<< get

-- | Shows the current 'Deck'
-- TODO: split out an org renderer
showDeck :: FAM FAResponse
showDeck = do
  deck <- use (game . deck)
  pure
    . mappend "* cards\n"
    . intercalate "\n"
    . fmap ("** " <>)
    $ deck ^.. folded
