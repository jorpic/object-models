
{-# LANGUAGE TemplateHaskell #-}
module AllModels where

import Model.Dictionaries
import Model.TH

mx = $(modelClasses)
