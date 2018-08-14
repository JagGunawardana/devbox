(paradox-require 'go-mode)
(paradox-require 'auto-complete)
(paradox-require 'go-autocomplete)
(paradox-require 'auto-complete-config)
(paradox-require 'helm-go-package)
(paradox-require 'swiper-helm)
(paradox-require 'yasnippet)
(paradox-require 'go-eldoc)
(paradox-require 'sr-speedbar)
(paradox-require 'bm)
(paradox-require 'racket-mode)
(paradox-require 'graphviz-dot-mode)
(paradox-require 'plantuml-mode)
(paradox-require 'make-mode)
(paradox-require 'ox-reveal)
(paradox-require 'cheatsheet)
(paradox-require 'paredit)

(ac-config-default)

(display-time-mode)
(set-face-attribute 'default nil :height 100)

'(paradox-require 'unicode-fonts)
'(unicode-fonts-setup)

; PlantUML
(add-to-list
    'org-src-lang-modes '("plantuml" . plantuml))

; reveal.js
(setq org-reveal-root "file:///home/jag.gunawardana/work/presentations/reveal/reveal.js-3.6.0/js/reveal.js")

; Powerline
(paradox-require 'powerline)
(paradox-require 'airline-themes)
(load-theme 'airline-papercolor)

(setq powerline-utf-8-separator-left        #xe0b0
      powerline-utf-8-separator-right       #xe0b2
      airline-utf-glyph-separator-left      #xe0b0
      airline-utf-glyph-separator-right     #xe0b2
      airline-utf-glyph-subseparator-left   #xe0b1
      airline-utf-glyph-subseparator-right  #xe0b3
      airline-utf-glyph-branch              #xe0a0
      airline-utf-glyph-readonly            #xe0a2
      airline-utf-glyph-linenumber          #xe0a1)

; bm bookmarks
(setq bm-restore-repository-on-load t)
(setq bm-cycle-all-buffers t)

; Clojure(script)
(paradox-require 'cider)
(setq cider-default-repl-command "lein")

; yasnippets
(setq yas-snippet-dirs '("~/.emacs.d/snippets"))
(yas-global-mode 1)

; Terraform
(paradox-require 'hcl-mode)
(paradox-require 'terraform-mode)
(custom-set-variables
   '(terraform-indent-level 4))

; Protobuf
(paradox-require 'protobuf-mode)

; Expand region
(paradox-require 'expand-region)
(require 'expand-region)

; Org mode
(paradox-require 'org)
(require 'org)
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))

; Org-babel
(paradox-require 'ob-http)
(require 'ob-http)
(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (http . t)))

; sr-speedbar
(setq speedbar-show-unknown-files t) ; show all files
(setq speedbar-use-images nil) ; use text for buttons
(setq sr-speedbar-right-side nil) ; put on left side

; ElPy
(paradox-require 'elpy)
(elpy-enable)

; Go stuff
(setq gofmt-command "goimports")
(defun my-go-mode-hook ()
  ; Customize compile command to run go build
  (if (not (string-match "go" compile-command))
      (set (make-local-variable 'compile-command)
           "go build -v && go test -v && go vet"))
  ; Go oracle
  ; (load-file "$GOPATH/src/golang.org/x/tools/cmd/oracle/oracle.el")
  ; Godef jump key binding
  (speedbar-add-supported-extension ".go")
  (setq imenu-generic-expression
    '(("type" "^type *\\([^ \t\n\r\f]*\\)" 1)
    ("func" "^func *\\(.*\\) {" 1)))
  )

(add-hook 'go-mode-hook 'my-go-mode-hook)
(add-hook 'go-mode-hook 'go-eldoc-setup)
(add-hook 'go-mode-hook (lambda ()
                            (local-set-key (kbd "M-.") 'godef-jump)
                            (local-set-key (kbd "M-*") 'pop-tag-mark)
                            (local-set-key (kbd "C-c d") 'godoc-at-point)
                            (local-set-key (kbd "C-c C-d") 'godoc)
                            (setq show-trailing-whitespace t)
                            (setq ethan-wspace-errors (remove 'tabs ethan-wspace-errors))
                            (add-hook 'before-save-hook 'gofmt-before-save)
                          ))

(setq hc-highlight-tabs-mode '(not go-mode terraform-mode))
(setq ethan-wspace-highlight-tabs-mode '(not go-mode terraform-mode))

(defun autocomplete-for-go ()
  (auto-complete-mode 1))
(add-hook 'go-mode-hook 'autocomplete-for-go)

(with-eval-after-load 'go-mode
  (require 'go-autocomplete))

; Custom behaviour
; Mac keys
(setq mac-command-modifier 'super)

; Change M-f to something sensible
(defun next-word (p)
   "Move point to the beginning of the next word, past any spaces"
   (interactive "d")
   (forward-word)
   (forward-word)
   (backward-word))
(global-set-key "\M-f" 'next-word)

; Key bindings
(global-set-key "\C-c\C-b" 'compile)
(global-set-key "\C-c\C-e" 'sr-speedbar-toggle)
(global-set-key "\C-c\C-s\C-c" 'avy-goto-char)
(global-set-key "\C-c\C-s\C-t" 'avy-goto-char-timer)
(global-set-key "\C-c\C-s\C-w" 'avy-goto-word-0)
(global-set-key "\C-c\C-s\C-l" 'avy-goto-line)
(global-set-key "\C-c\C-s\C-rc" 'avy-copy-region)
(global-set-key "\C-c\C-s\C-rm" 'avy-move-region)
(global-set-key "\C-c\C-s\C-p" 'avy-pop-mark)

(global-set-key "\C-c\C- " 'er/expand-region)
(global-set-key "\C-xo" 'ace-select-window)
(global-set-key "\C-xf" 'helm-projectile)
; used by paredit (global-set-key "\C-\M-n" 'windmove-down)
; used by paredit (global-set-key "\C-\M-p" 'windmove-up)
(global-set-key "\C-c\C-h" 'auto-complete)
(global-set-key "\C-c\C-i" 'yas-insert-snippet)
(global-set-key "\C-c\C-m" 'bm-toggle)
(global-set-key "\C-c\C-n"   'bm-next)

; Cheatsheet
(global-set-key "\C-h\C-s"   'cheatsheet-show)
(cheatsheet-add-group 'Cheatsheet
                      '(:key "C-h C-s" :description "show cheatsheet")
                      '(:key "C-q" :description "quit cheatsheet")
                      )
(cheatsheet-add-group 'Golang
                      '(:key "C-c C-b" :description "build")
                      )
(cheatsheet-add-group 'Cider
                      '(:key "C-x C-e" :description "Evaluate sexp")
                      '(:key "C-c M-n" :description "Set name space")
                      '(:key "C-c C-k" :description "Compile current file")
                      '(:key "C-c C-d C-d" :description "Doc at point")
                      '(:key "C-c C-d C-a" :description "Apropos search")
                      '(:key "M-." :description "Follow source")
                      '(:key "M-," :description "Pop follow source")
                      )

(cheatsheet-add-group 'helm
                      '(:key "C-xf" :description "helm find file")
                      '(:key "C-xcf" :description "helm multi find file")
                      '(:key "C-xci" :description "helm imenu")
                      )

(cheatsheet-add-group 'bookmarks
                      '(:key "C-xr m" :description "set bookmark")
                      '(:key "C-xr l" :description "list bookmarks")
                      '(:key "C-xr b" :description "jump to bookmark")
                      '(:key "C-c (C-)m" :description "Toggle bookmark")
                      '(:key "C-c C-n" :description "Jump to next bookmark")
                      )

(cheatsheet-add-group 'registers
                      '(:key "C-xr s" :description "store region")
                      '(:key "C-xr i" :description "Insert register")
                      '(:key "C-xr SPC" :description "Store point")
                      '(:key "C-xr j" :description "jump to register")
                      )

(cheatsheet-add-group 'nav
                      '(:key "C-c C-s C-t" :description "avy-goto-char-timer")
                      '(:key "C-c C-s C-w" :description "avy-goto-word")
                      '(:key "C-c C-s C-c" :description "avy-goto-char")
                      '(:key "C-c C-s C-l" :description "avy-goto-line")
                      '(:key "C-c C-s C-rm" :description "avy-move-region")
                      '(:key "C-c C-s C-rc" :description "avy-copy-region")
                      '(:key "C-c C-s C-p" :description "avy-pop-mark")
                      '(:key "C-l" :description "Re-centre point middle/top/bottom")
                      )

(cheatsheet-add-group 'general-code
                      '(:key "C-x C-i" :description "insert snippet")
                      '(:key "C-c C-e" :description "speedbar toggle")
                      )

(cheatsheet-add-group 'regions
                      '(:key "C-SPC" :description "Start region")
                      '(:key "C-x SPC" :description "Start rectangular region")
                      '(:key "C-u SPC" :description "Jump to mark")
                      '(:key "C-x C-x" :description "Exchange point and mark")
                      '(:key "C-c C- " :description "Expand region")
                      )

(cheatsheet-add-group 'sexp
                      '(:key "C-M-f" :description "Move forward by sexp")
                      '(:key "C-M-b" :description "Movekward by sexp")
                      '(:key "C-M-u" :description "Move up out of a list")
                      '(:key "C-M-d" :description "Move down into a list")
                      '(:key "C-M-n" :description "Move forward to next sexp")
                      '(:key "C-M-p" :description "Move backward to previous sexp")
                      '(:key "C-M-p" :description "Move backward to previous sexp")
                      '(:key "M-s" :description "Splice sexp")
                      '(:key "M-(" :description "Wrap sexp")
                      '(:key "M-\"" :description "Wrap string")
                      '(:key "C-)" :description "Forward slurp")
                      '(:key "C-(" :description "Backward slurp")
                      '(:key "C-}" :description "Forward barf")
                      '(:key "C-{" :description "Backward barf")
                      '(:key "M-r" :description "Raise sexp")
                      '(:key "M-S" :description "Split sexp")
                      '(:key "M-J" :description "Join sexp")
                      )

; Line numbers
(global-linum-mode t)
(setq linum-format "%d ")

; ace-isearch

;(global-ace-isearch-mode +1)
;(setq ace-isearch-function 'avy-goto-char)

; Sort out tabs to be 4 spaces
(setq default-tab-width 4)

; paredit
(global-set-key "\M-\"" 'paredit-meta-doublequote)
(global-set-key "\C-[[fs" 'paredit-forward-slurp-sexp)
(global-set-key "\C-[]bs" 'paredit-backward-slurp-sexp)
(global-set-key "\C-[[fb" 'paredit-forward-barf-sexp)
(global-set-key "\C-[]bb" 'paredit-backward-barf-sexp)

; Should not need this - as it is the default
;(global-set-key "\C-t", 'transpose-chars)
