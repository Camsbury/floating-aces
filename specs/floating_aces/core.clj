(ns floating-aces.core-spec
  (:require [clojure.spec.alpha :as s]))

(s/def ::tag keyword?)
(s/def ::tags (s/coll-of ::tag))
(s/def ::description string?)
(s/def ::name string?)
(s/def ::id uuid?)
(s/def ::card (s/keys :req [::name]
                      :opt [::description ::tags]))
(s/def ::deck (s/map-of ::id ::card))
(s/def ::shuffle (s/coll-of uuid?))
(s/def ::shuffles (s/map-of keyword? ::shuffle))
(s/def ::game (s/keys :req [::deck ::shuffles]))
