module FloatingAces.Parser (parseEvent) where
--------------------------------------------------------------------------------
import Prelude
--------------------------------------------------------------------------------
import FloatingAces.Type
--------------------------------------------------------------------------------
import qualified Data.Attoparsec.Text as AP
import qualified Data.Char as C
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

faParser :: Parser FAEvent
faParser
  =   showDeckParser
  <|> createCardParser

-- | Parses Raw Text into a Floating Aces Event
parseEvent :: Text -> Either String FAEvent
parseEvent = AP.parseOnly faParser
