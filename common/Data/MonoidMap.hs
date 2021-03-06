{-# LANGUAGE DeriveFoldable #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE TypeFamilies #-}
module Data.MonoidMap where

import Data.AppendMap (AppendMap)
import Data.AppendMap as Map
import Data.Semigroup (Semigroup, (<>))
import Reflex (Query, QueryResult, crop)

newtype MonoidMap k v = MonoidMap { unMonoidMap :: AppendMap k v }
  deriving (Show, Eq, Ord, Foldable)

monoidMap :: (Ord k, Eq v, Monoid v) => AppendMap k v -> MonoidMap k v
monoidMap = MonoidMap . Map.filter (/= mempty)

instance (Eq (QueryResult q), Ord k, Query q) => Query (MonoidMap k q) where
  type QueryResult (MonoidMap k q) = MonoidMap k (QueryResult q)
  crop (MonoidMap q) (MonoidMap qr) =
    -- This assumes that the query result of a null query should be null
    monoidMap $ Map.intersectionWith crop q qr

instance (Monoid a, Eq a, Ord k) => Semigroup (MonoidMap k a) where
  MonoidMap a <> MonoidMap b =
    let combine _ a' b' =
          let c = a' `mappend` b'
          in if c == mempty
               then Nothing
               else Just c
    in MonoidMap $ Map.mergeWithKey combine id id a b

instance (Ord k, Monoid a, Eq a) => Monoid (MonoidMap k a) where
  mempty = MonoidMap Map.empty
  mappend = (<>)
