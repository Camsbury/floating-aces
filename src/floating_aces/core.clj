(ns floating-aces.core
  (:require
   [floating-aces.render :as render]
   [floating-aces.example :as example])
  (:import (java.util UUID)))

(defn -main [name]
  (print (render/shuffle->org floating-aces.example/game name)))
(comment
  (println (UUID/randomUUID)))
