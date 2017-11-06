;;; select-script-mode.el --- sample major mode for editing select-script. -*- coding: utf-8; lexical-binding: t; -*-

;; Copyright © 2017, by Fin Christensen

;; Author: Fin Christensen ( christensen.fin@gmail.com )
;; Version: 0.1.0
;; Created: 03 Nov 2017
;; Keywords: languages
;; Homepage:

;; This file is not part of GNU Emacs.

;;; License:

;; You can redistribute this program and/or modify it under the terms of the GNU General Public License version 2.

;;; Commentary:

;; This mode provides basic syntax highlighting and indentation support for the select-script embedded programming language.

;;; Code:

(defvar select-script-mode-hook nil)
(defvar select-script-indent-offset 2
  "*Indentation offset for `select-script-mode`.")

(defun case-insensitive (words)
  (mapcar (lambda (word)
            (concat "\\(" (loop for char across word
                                concat (concat "[" (downcase (char-to-string char)) (upcase (char-to-string char)) "]"))
                    "\\)")) words))

(defun as-regex (words)
  (mapconcat 'identity words "\\|"))

(defun s2-indent-line ()
  "Indent current line as s2 code"
  (interactive)
  (let ((indent-col 0))
    (save-excursion
      (beginning-of-line)
      (condition-case nil
          (while t
            (backward-up-list 1)
            (when (looking-at "[(]")
              (setq indent-col (+ indent-col select-script-indent-offset))))
        (error nil)))
    (save-excursion
      (back-to-indentation)
      (when (and (looking-at "[)]") (>= indent-col select-script-indent-offset))
        (setq indent-col (- indent-col select-script-indent-offset))))
    (indent-line-to indent-col)))

;; define several category of keywords
(setq s2-comment "#.+$")
(setq s2-comment-delimiter "\\(/\\*\\)\\|\\(\\*/\\)")
(setq s2-function "\\$?\\w*")
(setq s2-constant "\\([0-9]+\\)\\|\\(0b[0-1]+\\)\\|\\(0o[0-8]+\\)\\|\\(0x[0-9a-zA-Z]+\\)")
(setq s2-constant2 '("TRUE" "FALSE" "NONE") )
(setq s2-keywords '("IF" "YIELD" "EXIT" "LOOP" "AS" "CONNECT BY" "FROM" "GROUP BY" "LIMIT"
                    "ORDER BY" "SELECT" "START WITH" "STOP WITH" "WHERE" "PROCEDURE" "PROC"
                    "REF" "RECUR" "AND" "OR" "XOR" "IN" "NOT") )
(setq s2-types '("DICT" "DICTIONARY" "LIST" "SET" "VAL" "VALUE" "VOID" "NO CYCLE" "UNIQUE"
                 "ASC" "ASCENDING" "DESC" "DESCENDING") )
(setq s2-functions '("help" "print" "mem" "del" "time" "len" "insert" "remove" "pop" "import") )

(setq s2-keywords-regex (concat "\\<\\(" (as-regex (case-insensitive s2-keywords)) "\\)\\>"))
(setq s2-types-regex (concat "\\<\\(" (as-regex (case-insensitive s2-types)) "\\)\\>"))
(setq s2-constant-regex (as-regex (case-insensitive s2-constant2)))
(setq s2-constant-regex (concat "\\<\\(" s2-constant "\\|" s2-constant-regex "\\)\\>"))
(setq s2-functions-regex (concat "\\<\\(" (as-regex (case-insensitive s2-functions)) "\\)\\>"))
(setq s2-functions-regex (concat "\\(" s2-functions-regex "\\)\\|\\(@\\)"))

;; create the list for font-lock.
;; each category of keyword is given a particular face
(setq s2-font-lock-keywords
      `(
        (,s2-comment . font-lock-comment-face)
        (,s2-comment-delimiter . font-lock-comment-delimiter-face)
        (,s2-constant-regex . font-lock-constant-face)
        (,s2-keywords-regex . font-lock-keyword-face)
        (,s2-types-regex . font-lock-type-face)
        (,s2-functions-regex . font-lock-builtin-face)
        (,s2-function . font-lock-function-name-face)
        ;; note: order above matters, because once colored, that part won't change.
        ;; in general, longer words first
        ))

;;;###autoload
(define-derived-mode select-script-mode fundamental-mode "select-script mode"
  "Major mode for editing s2c source code (SelectScript)…"

  ;; code for syntax highlighting
  (set (make-local-variable 'font-lock-defaults) '(s2-font-lock-keywords))

  ;; set line indentation function
  (set (make-local-variable 'indent-line-function) 's2-indent-line))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.[sS]2\\'" . select-script-mode))

;; clear memory. no longer needed
(makunbound 's2-comment)
(makunbound 's2-comment-delimiter)
(makunbound 's2-constant)
(makunbound 's2-constant2)
(makunbound 's2-keywords)
(makunbound 's2-types)
(makunbound 's2-function)
(makunbound 's2-functions)
(makunbound 's2-keywords-regex)
(makunbound 's2-types-regex)
(makunbound 's2-functions-regex)
(fmakunbound 'case-insensitive)
(fmakunbound 'as-regex)

;; add the mode to the `features' list
(provide 'select-script-mode)

;;; select-script-mode.el ends here
