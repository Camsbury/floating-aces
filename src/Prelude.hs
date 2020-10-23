{-# OPTIONS_GHC -fno-warn-deprecations #-}
--------------------------------------------------------------------------------
module Prelude
  ( module ClassyPrelude
  , module Control.Lens.Operators
  , module Control.Monad.State
  , throwMaybe
  , throwEither
  , inspect
  , inspectM
  ) where
--------------------------------------------------------------------------------
import ClassyPrelude
import Control.Lens.Operators hiding ((<.>), (<|))
import Control.Monad.Except
import Control.Monad.State hiding
  ( foldM
  , forM_
  , mapM_
  , sequence_
  , filterM
  , replicateM
  )
--------------------------------------------------------------------------------
import Control.Lens


-- | throws error if Nothing
throwMaybe :: MonadError e m => e -> Maybe a -> m a
throwMaybe e = maybe (throwError e) pure

-- | throws error if Nothing
throwEither :: MonadError e m => Either e a -> m a
throwEither = either throwError pure

-- | Prints a value annotated with the passed label and returns the input value.
inspect :: (Show a) => String -> a -> a
inspect label x = trace (label ++ ": " ++ show x) x
{-# WARNING inspect "'inspect' remains in code" #-}

-- | Prints a value annotated with the passed label and returns a monadic unit
inspectM :: (Show a, Monad m) => String -> a -> m ()
inspectM label x = traceM (label ++ ": " ++ show x)
{-# WARNING inspectM "'inspectM' remains in code" #-}
