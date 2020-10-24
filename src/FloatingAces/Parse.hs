module FloatingAces.Parse (parseEvent) where
--------------------------------------------------------------------------------
import Prelude
--------------------------------------------------------------------------------
import FloatingAces.Type
--------------------------------------------------------------------------------
import qualified Attoparsec.Data as AP hiding (string)
import qualified Data.Attoparsec.Text as AP
import qualified Data.Char as C
import qualified Data.UUID as UUID
--------------------------------------------------------------------------------
import Data.Attoparsec.Text (Parser)
--------------------------------------------------------------------------------

showGameParser :: Parser GameEvent
showGameParser = do
  AP.string "show-game"
  pure $ ShowGame

createCardParser :: Parser GameEvent
createCardParser = do
  AP.string "create-card"
  AP.space
  name <- AP.takeTill C.isSpace
  pure $ CreateCard name

createShuffleParser :: Parser GameEvent
createShuffleParser = do
  AP.string "create-shuffle"
  AP.space
  name <- AP.takeTill C.isSpace
  pure $ CreateShuffle name

shuffleCardParser :: Parser GameEvent
shuffleCardParser = do
  AP.string "shuffle-card"
  AP.space
  cardID <- AP.uuid
  AP.space
  shuffleID <- AP.uuid
  pure $ ShuffleCard cardID shuffleID

priorityOverParser :: Parser GameEvent
priorityOverParser = do
  AP.string "priority-over"
  AP.space
  greaterCardID <- AP.uuid
  AP.space
  lesserCardID <- AP.uuid
  pure $ PriorityOver greaterCardID lesserCardID

faParser :: Parser GameEvent
faParser
  =   showGameParser
  <|> createShuffleParser
  <|> createCardParser
  <|> shuffleCardParser
  <|> priorityOverParser

-- | Parses Raw Text into a Floating Aces Event
parseEvent :: Text -> Either String GameEvent
parseEvent = AP.parseOnly faParser
