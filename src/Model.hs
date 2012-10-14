
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DeriveDataTypeable #-}

module Model
  (Object
  ,Field(..) -- FIXME: Model.Internal
  ,Req, Opt
  ,GetSet(..)
  ,Ident
  ,Model(..)
  ) where

import Data.Time (UTCTime)
import Data.Text (Text)
import Data.Map (Map)
import qualified Data.Map as Map
import Data.Dynamic
import Data.Aeson.Types hiding (Object)
import qualified Data.Aeson as Aeson


-- | Object is represented as a `Map` of `Dynamic`s.
-- Fantom type parameter is used to discover actual contents of the map.
-- Constructor is not exported so object could be used only in a type-safe way.
newtype Object cls
  = Object (Map Text Dynamic)
  deriving Typeable


-- | Each model is represented as a type-class whose methods are field
-- descriptions.
-- Default class method implementations allow in-place value-level field information.
--          FIXME: example
data Field opt cls typ = Field
  {fName :: Text
  ,fDesc :: Text
  }


----------------------------------------------------------------------
class GetSet opt typ where
  type GetRes opt typ
  get :: Typeable typ => Object cls -> Field opt cls typ -> GetRes opt typ


data Req
instance GetSet Req typ where
  type GetRes Req typ = typ
  get (Object obj) f
    = maybe (error "Impossible happened: Req") id
    $ getByName obj $ fName f


data Opt
instance GetSet Opt typ where
  type GetRes Opt typ = Maybe typ
  get (Object obj) f = getByName obj $ fName f


getByName :: Typeable typ => Map Text Dynamic -> Text -> Maybe typ
getByName obj f
  -- FIXME: report object Id and field name
  = fmap (`fromDyn` error "Impossible happened: Dynamic")
  $ Map.lookup f obj


----------------------------------------------------------------------
newtype Ident cls
  = Ident Text
  deriving Typeable


class Model cls where
  ident :: Field Req cls (Ident cls)
  ident = Field "ident" "Уникальный идентификатор объекта"

  ctime :: Field Req cls UTCTime
  ctime = Field "ctime" "Дата создания объекта"

  mtime :: Field Req cls UTCTime
  mtime = Field "mtime" "Дата модификации объекта"

  modelDesc :: ModelDesc cls
  modelDesc = undefined -- TODO: generated by TH $(genModelDesc ''Case)

-- TODO: instance Model cls => FromJSON (Object cls)

data ModelDesc cls = ModelDesc
  {modelName :: Text
  -- fields
  }

-- $(mkModel ''Case)
-- => instance Model Case where modelDesc = "{}"
-- => instance ToJSON Case
-- => instance FromJSON Case

----------------------------------------------------------------------
jsonGet
  :: FromJSON typ
  => Aeson.Object -> Field opt cls typ -> Parser typ
jsonGet jsn (Field f _) = jsn .: f

jsonCopy
  :: (Typeable typ, FromJSON typ)
  => Aeson.Object -> Field opt cls typ -> Map Text Dynamic
  -> Parser (Map Text Dynamic)
jsonCopy jsn f obj = do
  v <- jsonGet jsn f
  return $ Map.insert (fName f) (toDyn v) obj

{-
dispatcher = $(mkDispatcher)
dispatcher modelName json = case modelName of
  "Case" -> do
    obj <- Aeson.decode json :: IO (Object Case)
    changes <- runTriggers obj
-}