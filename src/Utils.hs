module Utils
  ( module Utils
  ) where
--------------------------------------------------------------------------------
import Prelude
--------------------------------------------------------------------------------
import Control.Monad.State
import FloatingAces.Type
--------------------------------------------------------------------------------

-- | Logs the current state
logState :: FAM ()
logState = liftIO . print =<< get
