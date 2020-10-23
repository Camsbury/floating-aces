module FloatingAces.Parser (parseEvent) where
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

showDeckParser :: Parser FAEvent
showDeckParser = do
  AP.string "show-deck"
  pure $ ShowDeck

createCardParser :: Parser FAEvent
createCardParser = do
  AP.string "create-card"
  AP.space
  name <- AP.takeTill C.isSpace
  pure $ CreateCard name

createShuffleParser :: Parser FAEvent
createShuffleParser = do
  AP.string "create-shuffle"
  AP.space
  name <- AP.takeTill C.isSpace
  pure $ CreateShuffle name

shuffleCardParser :: Parser FAEvent
shuffleCardParser = do
  AP.string "shuffle-card"
  AP.space
  cardID <- AP.uuid
  AP.space
  shuffleName <- AP.takeTill C.isSpace
  pure $ ShuffleCard cardID shuffleName

priorityOverParser :: Parser FAEvent
priorityOverParser = do
  AP.string "priority-over"
  AP.space
  greaterCardID <- AP.uuid
  AP.space
  lesserCardID <- AP.uuid
  pure $ PriorityOver greaterCardID lesserCardID

faParser :: Parser FAEvent
faParser
  =   showDeckParser
  <|> createShuffleParser
  <|> createCardParser
  <|> shuffleCardParser
  <|> priorityOverParser

-- | Parses Raw Text into a Floating Aces Event
parseEvent :: Text -> Either String FAEvent
parseEvent = AP.parseOnly faParser
