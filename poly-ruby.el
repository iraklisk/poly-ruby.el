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

(defconst poly-ruby--langs (regexp-opt '("js" "sql" "html")))

;; (defun poly-ruby--mode-matcher ()
;;   (when (re-search-forward "[\r\n]+[ \t]*<<~[:word:]" (point-at-eol) t)
;;     (match-string-no-properties 2)))

(define-auto-innermode poly-ruby-innermode
  :fallback-mode 'host
  :head-mode 'host
  :tail-mode 'host
  :head-matcher (cons (format "^[ \t]*\\(<<~%s\n\\)" poly-ruby--langs) 1)
  :tail-matcher (cons (format "\\(^[ \t]*%s\n\\)" poly-ruby--langs) 1)
  :mode-matcher (cons "<<~{?\\(?:lang *= *\\)?\\([^ \t\n;=,}]+\\)" 1))
;;  :mode-matcher #'poly-ruby--mode-matcher)

(define-hostmode poly-ruby-custom-hostmode
  :mode 'ruby-mode
  :protect-font-lock nil
  :protect-syntax t)

;;;###autoload  (autoload 'poly-ruby-mode "poly-ruby")
(define-polymode poly-ruby-mode
  :hostmode 'poly-ruby-custom-hostmode
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
