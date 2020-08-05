(ns floating-aces.render
  (:require [floating-aces.example :as example]))

(defn- insert-at [index acc card]
  (let [[before after] (split-at index acc)]
    (vec (concat before [card] after))))

(defn- find-parent [coll index]
  (->> coll
       (map-indexed vector)
       (filter #(= index (-> % second :index)))
       first))

(defn- insert-card
  [acc [index card]]
  (case index
    0 [{:index 0 :card (assoc card :depth 0)}]
    (let [p-index (quot (dec index) 2)
          [ri {{:keys [depth]} :card}] (find-parent acc p-index)]
      (insert-at (inc ri) acc
       {:index index :card (assoc card :depth (inc depth))}))))

(defn- card->org [{:keys [depth] :floating-aces.core/keys [name] :as card}]
  (str (apply str (repeat (inc depth) "*")) " " name "\n"))

(defn shuffle->org
  "Renders a given shuffle to be displayed by emacs org-mode"
  [{:floating-aces.core/keys [deck shuffles]} shuffle-name]
  (->> shuffle-name
       (get shuffles)
       (map #(assoc (get deck %) :floating-aces.core/id %))
       (map-indexed vector)
       (reduce insert-card [])
       (map :card)
       (map card->org)
       (apply str)))
