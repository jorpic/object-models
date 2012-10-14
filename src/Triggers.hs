

{-# LANGUAGE ExistentialQuantification #-}
module Triggers where

import Data.Time (UTCTime)
import Model
import Model.Case


type TriggerMonad = IO

data Trigger cls = forall typ opt . Trigger
  {tField :: Field opt cls typ
  ,tFns   :: [typ -> Ident cls -> TriggerMonad ()]
  }

class Triggers cls where
  triggers :: [Trigger cls]

runTriggers
  :: (Model cls, Triggers cls)
  => Object cls -> TriggerMonad ()
runTriggers obj = do
  let i = obj `get` ident
  let runT (Trigger f fns) = do
        let v = obj `get` f
        mapM_ (\fn -> fn v i) fns
  mapM_ runT triggers
  
instance Triggers Case where
  triggers =
    [Trigger ctime [\t i -> print (t :: UTCTime)]
    ,Trigger ident [\t i -> print ""]
    ]
