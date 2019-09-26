;;; org-plist.el --- Update values in plist by C-c C-c -*- lexical-binding: t; -*-

;; Copyright (C) 2019 Takaaki ISHIKAWA

;; Author: Takaaki ISHIKAWA <takaxp at ieee dot org>
;; Keywords: convenience
;; Version: 0.0.1
;; Maintainer: Takaaki ISHIKAWA <takaxp at ieee dot org>
;; URL: https://github.com/takaxp/org-plist
;; Package-Requires: ((emacs "25.1"))
;; Twitter: @takaxp

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; Update values in plist by C-c C-c
;; (add-to-list 'org-plist-dict '("OPTIONS_FOO" "org-onit-foo-options"))
;; (add-to-list 'org-plist-dict '("OPTIONS_BAR" org-onit-bar-options))
;; then just type C-c C-c on the header of org files.

;;; Change Log:

;;; Code:

(eval-when-compile
  (require 'cl-lib nil t))

(defgroup org-plist nil
  "Hoge."
  :group 'convenience)

(defcustom org-plist-dict nil
  "Hoge."
  :type '(choice '(alist :value-type (group string string))
                 '(alist :value-type (group string symbol)))
  :group 'org-plist)

;;;###autoload
(defun org-plist ()
  "Hoge."
  (when org-plist-dict
    (let ((key (org-element-property :key (org-element-at-point)))
          (result nil))
      (cl-loop for op in org-plist-dict do
               (when (equal key (nth 0 op))
                 (let ((options (org-plist--find-key key))
                       (plist (intern-soft (nth 1 op))))
                   (if (and (boundp plist) plist)
                       (when options
                         (org-plist--update (eval plist) options)
                         (setq result (eval plist)))
                     (user-error "\"%s\" is not defined" plist)))))
      ;; visual feedback and send the result to `org-ctrl-c-ctrl-c'
      (when result (message "%s" result)))))

(defun org-plist--find-key (key)
  "Hoge.
KEY"
  (let ((element (org-element-at-point)))
    (when (equal (org-element-property :key element) key)
      (org-element-property :value element))))

(defun org-plist--update (plist options)
  "Hoge.
PLIST
OPTIONS"
  (with-temp-buffer
    (insert options)
    (goto-char (point-min))
    (while (re-search-forward "\\([^: ]+\\):\\([^ ]+\\)" nil t)
      (let ((key (match-string 1))
            (value (match-string 2)))
        (plist-put plist (intern (concat ":" key)) (intern value))))))

(add-hook 'org-ctrl-c-ctrl-c-hook #'org-plist)

(provide 'org-plist)

;;; org-plist.el ends here
