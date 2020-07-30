(ns floating-aces.core
  (:require
   [floating-aces.render :as render]
   [floating-aces.example :as example])
  (:import (java.util UUID)))

(defn -main [game name]
  (print (render/shuffle->org game (keyword name))))
(comment
  (println (UUID/randomUUID)))
