
{-# LANGUAGE TemplateHaskell #-}

module Model.Dictionaries where

import Data.Text (Text)

import Model
import Model.TH


class Dict cls where
  value :: Field Req cls Text
  value = Field "value" "Текстовое значение"
  active :: Field Req cls Bool
  active = Field "active" "Используется значение или нет"
$(regModel ''Dict)

class OrdDict cls where
  order :: Field Req cls Int
  order = Field "order" "Закон и порядок"
$(regModel ''OrdDict)

class SubDict parent cls where
  parent :: Field Req cls (Ident parent)
  parent = Field "parent" "Родитель"
$(regModel ''SubDict)


data CallerType
instance Dict CallerType
instance Model CallerType

data CallType
instance Dict CallType
instance SubDict CallerType CallType
instance Model CallType


