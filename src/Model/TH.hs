
{-# LANGUAGE TemplateHaskell #-}

module Model.TH where


import Control.Concurrent.MVar
import System.IO.Unsafe
import Language.Haskell.TH


{-# NOINLINE xxx #-}
xxx :: MVar [Name]
xxx = unsafePerformIO $ newMVar []

regModel :: Name -> Q [Dec]
regModel cls = runIO $ do
  -- FIXME: Do we need some thread safety here?
  modifyMVar_ xxx (return . (cls:))
  return []


modelClasses :: Q Exp
modelClasses = do
  names <- runIO $ readMVar xxx
  infos <- mapM reify names
  return $ ListE $ map (LitE . StringL . show) names
