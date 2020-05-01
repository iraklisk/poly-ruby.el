;;; poly-ruby.el --- Provides poly-ruby-mode

;; Copyright (c) 2017-2018 Akinori MUSHA
;;
;; All rights reserved.
;;
;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions
;; are met:
;; 1. Redistributions of source code must retain the above copyright
;;    notice, this list of conditions and the following disclaimer.
;; 2. Redistributions in binary form must reproduce the above copyright
;;    notice, this list of conditions and the following disclaimer in the
;;    documentation and/or other materials provided with the distribution.
;;
;; THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
;; ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
;; ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
;; FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
;; DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
;; OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
;; HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
;; LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
;; OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
;; SUCH DAMAGE.

;; Author: Akinori MUSHA <knu@iDaemons.org>
;; URL: https://github.com/knu/poly-ruby.el
;; Created: 12 May 2017
;; Version: 0.3.1
;; Package-Requires: ((emacs "25") (polymode "0.1.2"))
;; Keywords: languages

;;; Commentary:
;;
;; This package defines poly-ruby-mode, which introduces polymode for
;; here-documents in a ruby script.
;;
;; Currently editing actions against sexps does not work properly in
;; polymode, so it is advised you turn this mode on only when
;; necessary.
;;
;;   (define-key ruby-mode-map (kbd "C-c m") 'toggle-poly-ruby-mode)
;;
;;; Code:

(require 'polymode)

(eval-and-compile
  (defconst poly-ruby/heredoc-head-regexp
    "\\(<\\)<\\([~-]\\)?\\(\\([_[:word:]]+\\)\\|[\"]\\([^\"]+\\)[\"]\\|[']\\([^']+\\)[']\\)"
    "Regexp to match the beginning of a ruby heredoc."))

(defun poly-ruby/heredoc-head-matcher (ahead)
  (save-excursion
    (if (re-search-forward poly-ruby/heredoc-head-regexp nil t ahead)
        (let ((head (cons (match-beginning 0) (match-end 0))))
          (save-match-data
            (goto-char (car head))
            (and (not (looking-at "[[:digit:]]"))
                 (not (looking-back "[_[:word:]]" nil))
                 head))))))

(defun poly-ruby/heredoc-tail-matcher (ahead)
  (save-excursion
    (save-match-data
      (beginning-of-line 0)
      (if (poly-ruby/heredoc-head-matcher 1)
          (let* ((noindent (string= "" (match-string 1)))
                 (word (match-string 3))
                 (tail-reg (concat (if noindent "^" "^[ \t]*")
                                   (regexp-quote word)
                                   "\\(?:\n\\|\\'\\)")))
            (goto-char (match-end 0))
            (if (re-search-forward tail-reg nil t 1)
                (cons (match-beginning 0) (match-end 0))
              (cons (point-max) (point-max))))))))

(defun poly-ruby/heredoc-mode-matcher ()
  (save-match-data
    (poly-ruby/heredoc-head-matcher 1)
    (let* ((word (intern (downcase (match-string 3))))
           (ruby (intern (replace-regexp-in-string
                          "-mode\\'" ""
                          (symbol-name (oref (oref pm/polymode -hostmode) mode)))))
           (name (if (eq word 'ruby) ruby word)))
      name)))

(define-auto-innermode poly-ruby-innermode
  :fallback-mode 'host
  :head-mode 'host
  :tail-mode 'host
  :head-matcher 'poly-ruby/heredoc-head-matcher
  :tail-matcher 'poly-ruby/heredoc-tail-matcher
  :mode-matcher 'poly-ruby/heredoc-mode-matcher
  :body-indent-offset 'ruby-indent-level
  :indent-offset 'ruby-indent-level)

(defun poly-ruby-mode-fix-indent-function ()
  ;; smie-indent-line does not work properly in polymode
  (setq-local indent-line-function 'ruby-indent-line))

(defcustom poly-ruby-mode-hook '(poly-ruby-mode-fix-indent-function)
  "Hook run when entering poly-ruby-mode."
  :type 'hook
  :group 'polymodes)

(add-hook 'polymode-init-host-hook
          (lambda ()
            (cond ((eq major-mode 'ruby-mode)
                   (run-hooks 'poly-ruby-mode-hook)))))

;;;###autoload  (autoload 'poly-ruby-mode "poly-ruby")
(define-polymode poly-ruby-mode
  :hostmode 'poly-ruby-hostmode
  :innermodes '(poly-ruby-innermode))

;;;###autoload
(defun toggle-poly-ruby-mode ()
  "Toggle poly-ruby-mode."
  (interactive)
  (if (bound-and-true-p polymode-mode)
      (ruby-mode)
    (poly-ruby-mode)))

 ;;;###autoload
(add-to-list 'auto-mode-alist '("\\.rb\\'" . poly-ruby-mode))

(provide 'poly-ruby)
;;; poly-ruby.el ends here
