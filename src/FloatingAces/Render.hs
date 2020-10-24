module FloatingAces.Render (renderOrg) where
--------------------------------------------------------------------------------
import Prelude
--------------------------------------------------------------------------------
import FloatingAces.Type
--------------------------------------------------------------------------------
import Data.UUID    (UUID)
import Data.Default (Default(..))
import Text.Pandoc  (Pandoc(..))
-- import Text.Pandoc.Definition -- needed?
--------------------------------------------------------------------------------
import qualified Control.Lens as L
import qualified Data.UUID    as UUID
import qualified Text.Pandoc  as P
--------------------------------------------------------------------------------

-- | Create an identity attribute for pandoc
idToAttr :: UUID -> P.Attr
idToAttr ident = ((UUID.toText ident), mempty, mempty)

class ToPandoc a where
  toPandoc :: a -> [P.Block]

instance ToPandoc (CardID, Card) where
  toPandoc (ident, card)
    = P.Header 3 (idToAttr ident) [P.Str $ card ^. cardName]
    : [P.Header 4 P.nullAttr [P.Str "Priority Over"]]
    <> (toPandoc =<< (card ^.. priorityOver . L.folded))

instance ToPandoc Deck where
  toPandoc d = toPandoc =<< d ^@.. L.ifolded

-- TODO: make these give useful info
instance ToPandoc ShuffleEvent where
  toPandoc (InsertCard cardID)
    = [P.Header 5 P.nullAttr [P.Str "Insert Card"]]
  toPandoc (SwapCards a b)
    = [P.Header 5 P.nullAttr [P.Str "Swap Cards"]]
  toPandoc (DeleteCard cardID)
    = [P.Header 5 P.nullAttr [P.Str "Delete Card"]]
  toPandoc PopCard
    = [P.Header 5 P.nullAttr [P.Str "Pop Card"]]
  toPandoc (BubbleUp cardID)
    = [P.Header 5 P.nullAttr [P.Str "Bubble Up"]]
  toPandoc (BubbleDown cardID)
    = [P.Header 5 P.nullAttr [P.Str "Bubble Down"]]

instance ToPandoc CardID where
  toPandoc cardID
    = [P.Header 5 (idToAttr cardID) [P.Str "Card"]]

instance ToPandoc (ShuffleID, Shuffle) where
  toPandoc (ident, shuffle)
    = P.Header 3 (idToAttr ident) [P.Str $ shuffle ^. shuffleName]
    : [P.Header 4 P.nullAttr [P.Str "Cards"]]
    -- TODO: render whole card in monadic variant
    <> (toPandoc =<< (shuffle ^.. cards . L.folded))
    <> [P.Header 4 P.nullAttr [P.Str "Event Queue"]]
    <> (toPandoc =<< (shuffle ^.. eventQueue . L.folded))

instance ToPandoc Game where
  toPandoc g
    = P.Header 1 P.nullAttr [P.Str "Game"]
    : [P.Header 2 P.nullAttr [P.Str "Deck"]]
    <> (toPandoc (g ^. deck))
    <> [P.Header 2 P.nullAttr [P.Str "Shuffles"]]
    <> (toPandoc =<< (g ^@.. shuffles . L.ifolded))

-- | renders the data structure to org or the pandoc error
renderOrg :: ToPandoc a => a -> Text
renderOrg
  = either tshow id
  . P.runPure
  . P.writeOrg def
  . Pandoc mempty
  . toPandoc
