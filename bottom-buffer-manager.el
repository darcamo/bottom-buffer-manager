;;; bottom-buffer-manager.el --- Helper function to configure display-buffer-alist.  -*- lexical-binding: t; -*-

;; Copyright (C) 2025  Darlan Cavalcante Moreira

;; Author: Darlan Cavalcante Moreira <darcamo@gmail.com>
;; Version: 0.1
;; Package-Requires: ((emacs "28.1") (f "0.20.0") (s "1.12.0") (json "1.5") (dash "2.19.1") (tablist "1.1"))
;; Homepage: https://github.com/darcamo/bottom-buffer-manager
;; URL: https://github.com/darcamo/bottom-buffer-manager

;; This file is not part of GNU Emacs

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


;;; Commentary:

;; Defines a function that can be used in display-alist to display a buffer at
;; the bottom of the frame.


;;; Code:

;; Defines a bbm-match-strings custom variable that can receive a list of strings
(defcustom bbm-match-strings nil
  "List of buffer names to match for bottom buffer display."
  :type '(repeat string)
  :group 'bottom-buffer-manager)


(defun bbm--get-first-buffer-that-should-use-compilation-window ()
  "Get the window displaying one of my custom compilation buffers.

These are just names of buffers that I treat as compilation buffers."
  (let* ((regexp (regexp-opt bbm-match-strings))
         (first-matched-buffer
          (seq-find
           (lambda (buf)
             (string-match-p regexp (buffer-name buf)))
           (buffer-list))))
    (when first-matched-buffer
      (get-buffer-window first-matched-buffer))))


(defun bbm-display-action-function (buffer action)
  "An action function receiving a BUFFER and an ACTION.

This action function is designed to be used in `display-buffer-alist'."

  (let* ((existing-buffer-window (get-buffer-window (buffer-name buffer)))
         (compilation-window (get-buffer-window "*compilation*"))
         (other-possible-window
          (bbm--get-first-buffer-that-should-use-compilation-window))
         (desired-window
          (or existing-buffer-window compilation-window other-possible-window)))
    (if desired-window
        (set-window-buffer desired-window buffer)

      ;; Add (side . bottom) to the ACTION alist if not already present
      (unless (assq 'side action)
        (setf (alist-get 'side action) 'bottom))

      ;; Fall back to displaying buffer at the bottom
      (display-buffer-in-side-window buffer action))))


(provide 'bottom-buffer-manager)

;;; bottom-buffer-manager.el ends here

;; Local Variables:
;; read-symbol-shorthands: (("bbm-" . "bottom-buffer-manager-"))
;; End:
