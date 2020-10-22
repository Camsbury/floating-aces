module Main
  ( module Main
  ) where
--------------------------------------------------------------------------------
import Prelude
--------------------------------------------------------------------------------
import Control.Monad.State
--------------------------------------------------------------------------------
import FloatingAces (FAM, runFA)
import Network.Socket
  ( Family(..)
  , SocketType(..)
  , SockAddr(..)
  , Socket
  )
import Data.Default (Default(..))
--------------------------------------------------------------------------------
import qualified Network.Socket            as S
import qualified Network.Socket.ByteString as BS
import qualified Data.ByteString.Char8     as C
import qualified System.Directory          as Dir
import qualified System.Environment        as Env

-- | Runs an IPC server
main :: IO ()
main = do
  -- will error if the arg isn't provided as so
  [socketPath] <- fmap unpack <$> getArgs
  Dir.removePathForcibly socketPath
  S.withSocketsDo $ do
    socket <- S.socket AF_UNIX Stream 0
    S.bind socket $ SockAddrUnix socketPath
    S.listen socket S.maxListenQueue
    (conn, _) <- S.accept socket
    (`runStateT` def) $ do
      conversation conn
    S.close conn
    S.close socket
  Dir.removePathForcibly socketPath

conversation :: Socket -> FAM ()
conversation conn = do
  request <- liftIO $ BS.recv conn 1024
  unless (C.null request) $ do
    resp <- runFA (decodeUtf8 request)
    liftIO . BS.send conn $ encodeUtf8 resp
    conversation conn
