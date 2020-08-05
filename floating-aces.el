;;; floating aces

;; Author: Cameron Kingsbury <camsbury7@gmail.com>
;; URL: https://github.com/Camsbury/priorganize.el
;; Created: July 29, 2020
;; Keywords: org, todo
;; Package-Requires: ((parseedn "20200419.1124") (emacs "24") (babashka "0.1.3")
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

(require 'parseedn)
(require 'f)

(defun floating-aces ()
  "Runs the program"
  (message "TBD")) ; TODO: implement

(progn
  (switch-to-buffer "*render*")
  (with-current-buffer "*render*"
    (read-only-mode -1)
    (erase-buffer)
    (insert (shell-command-to-string "bb --classpath src --main floating-aces.core example"))
    (org-mode)
    (outline-show-all)
    (read-only-mode 1)))

(provide 'floating-aces)
