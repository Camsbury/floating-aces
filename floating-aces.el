;;; floating aces

;; Author: Cameron Kingsbury <camsbury7@gmail.com>
;; URL: https://github.com/Camsbury/floating-aces.el
;; Created: July 29, 2020
;; Keywords: org, todo
;; Package-Requires: ((emacs "24"))
;; Version: 0.1
;; Copyright (C) 2020  Cameron Kingsbury

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

(require 'f)

(setq fa-server-name "*floating-aces-server*")
(setq fa-client-name "*floating-aces-client*")
(setq fa-socket-path "/tmp/floating-aces.ipc")

(defun fa-filter (proc ev)
  (message "%s" ev))

(defun fa-init () ;; TODO: Jump to client and run initial request
  "Starts the floating aces ipc client and server"
  (interactive)

  ;; start server
  (make-process
   :name fa-server-name
   :buffer (get-buffer-create fa-server-name)
   :command (list
             (concat default-directory "result/bin/floating-aces")
             fa-socket-path))

  ;; wait for server to start
  (let ((counter 10))
    (while (or
            (/= 0 counter)
            (not (process-live-p (get-process fa-server-name))))
      (sleep-for 0 100)
      (setq counter (- counter 1))))

  ;; start client
  (make-network-process
   :name fa-client-name
   :family 'local
   :service fa-socket-path
   :nowait t
   :coding '(utf-8 . utf-8)
   :buffer (get-buffer-create fa-client-name)
   :noquery t
   :filter #'fa-filter
   :sentinel #'fa-filter))

(defun fa-quit ()
  "Quits floating aces"
  (interactive)
  (delete-process (get-process fa-server-name))
  (kill-buffer fa-server-name)
  (delete-process (get-process fa-client-name))
  (kill-buffer fa-client-name))

(defun fa-send-message (s)
  "Sends a message to the server"
  (process-send-string (get-process fa-client-name) s))

(defun fa-create-card (name)
  "Creates a card with the given name"
  (interactive "sCard name: ")
  (fa-send-message (concat "create-card " name)))

(defun fa-show-game ()
  "Shows the deck in an org file"
  (interactive)
  (fa-send-message "show-game"))

(comment
 (fa-send-message "create-card thing3")
 (fa-send-message "show-game"))

(provide 'floating-aces)
