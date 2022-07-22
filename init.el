(require 'package)

;; Add melpa to your packages repositories
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

(package-initialize)

;; Install use-package if not already installed
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)

;; ------------------------------- global options ------------------

;; (load-theme 'deeper-blue t)
(global-display-line-numbers-mode)

;; open buffers in read-only mode by default
;; toggle with C-x C-q
;; (add-hook 'find-file-hook (lambda () (setq buffer-read-only t)))

(column-number-mode t)
(global-display-fill-column-indicator-mode)
(setq-default display-fill-column-indicator-column 120)

(global-set-key (kbd "C-x 1")
  (lambda ()
  (interactive)
  (if (yes-or-no-p (concat "Really close all windows in this frame except"
  (buffer-name) "? "))
  (delete-other-windows))))

(setq show-paren-delay 0)
(show-paren-mode 1)

;; ----------------------------- find-files ----------------------

;; https://github.com/redguardtoo/find-file-in-project
(use-package find-file-in-project
  :ensure
  :config
  (global-set-key (kbd "C-c f") 'find-file-in-project)
  )

;; ----------------------------- which-key -----------------------

;; Which-key to get hints when typing command prefixes
(use-package which-key
  :ensure
  :diminish
  :config
  ;; Allow C-h to trigger which-key before it is done automatically
  (setq which-key-show-early-on-C-h t)
  ;; make sure which-key doesn't show normally but refreshes quickly after it is
  ;; triggered.
  (setq which-key-idle-delay 10000)
  (setq which-key-idle-secondary-delay 0.05)
  (which-key-mode)
  ;; (which-key-setup-side-window-bottom)
  ;; (setq which-key-idle-delay 0.1)
)

;; ----------------------------- treemacs -----------------------

(use-package treemacs
  :ensure
  :config
  (global-set-key [f8] 'treemacs)
  (setq lsp-enable-file-watchers nil)
  (setq treemacs-no-png-images t)
  ;; (setq treemacs-toggle-fixed-width t)
  ;; (setq treemacs-width 55)
)

(if (string= (system-name) "precision.onedigit.org")
  (setq treemacs-width 55)
  (setq treemacs-width 55)
  )

(when window-system
  (use-package treemacs
  :config
  (set-face-attribute 'treemacs-root-face nil
                        :foreground (face-attribute 'default :foreground)
                        :height 1.0
                        :weight 'normal)))

;; ----------------------------- magit -----------------------------

(use-package magit
  :ensure
  :config
  (global-set-key (kbd "C-x g") 'magit-status)
  (setq magit-refresh-status-buffer nil))


;; ---------------------------- scala -----------------------------

;; Enable defer and ensure by default for use-package
;; Keep auto-save/backup files separate from source code:  https://github.com/scalameta/metals/issues/1027
(setq use-package-always-defer t
      use-package-always-ensure t
      backup-directory-alist `((".*" . ,temporary-file-directory))
      auto-save-file-name-transforms `((".*" ,temporary-file-directory t)))

;; Enable scala-mode for highlighting, indentation and motion commands
(use-package scala-mode
  :interpreter
    ("scala" . scala-mode))

;; Enable sbt mode for executing sbt commands
(use-package sbt-mode
  :commands sbt-start sbt-command
  :config
  ;; WORKAROUND: https://github.com/ensime/emacs-sbt-mode/issues/31
  ;; allows using SPACE when in the minibuffer
  (substitute-key-definition
   'minibuffer-complete-word
   'self-insert-command
   minibuffer-local-completion-map)
   ;; sbt-supershell kills sbt-mode:  https://github.com/hvesalai/emacs-sbt-mode/issues/152
   (setq sbt:program-options '("-Dsbt.supershell=false"))
)

;; Enable nice rendering of diagnostics like compile errors.
(use-package flycheck
  :init (global-flycheck-mode))

(use-package lsp-mode
  ;; Optional - enable lsp-mode automatically in scala files
  :hook  (scala-mode . lsp)
         (lsp-mode . lsp-lens-mode)
  :config
  ;; Uncomment following section if you would like to tune lsp-mode performance according to
  ;; https://emacs-lsp.github.io/lsp-mode/page/performance/
  ;;       (setq gc-cons-threshold 100000000) ;; 100mb
  ;;       (setq read-process-output-max (* 1024 1024)) ;; 1mb
  ;;       (setq lsp-idle-delay 0.500)
  ;;       (setq lsp-log-io nil)
  ;;       (setq lsp-completion-provider :capf)
  (setq lsp-prefer-flymake nil))

;; Add metals backend for lsp-mode
(use-package lsp-metals)

;; Enable nice rendering of documentation on hover
;;   Warning: on some systems this package can reduce your emacs responsiveness significally.
;;   (See: https://emacs-lsp.github.io/lsp-mode/page/performance/)
;;   In that case you have to not only disable this but also remove from the packages since
;;   lsp-mode can activate it automatically.
(use-package lsp-ui)

;; lsp-mode supports snippets, but in order for them to work you need to use yasnippet
;; If you don't want to use snippets set lsp-enable-snippet to nil in your lsp-mode settings
;;   to avoid odd behavior with snippets and indentation
(use-package yasnippet)

;; Use company-capf as a completion provider.
;;
;; To Company-lsp users:
;;   Company-lsp is no longer maintained and has been removed from MELPA.
;;   Please migrate to company-capf.
(use-package company
  :hook (scala-mode . company-mode)
  :config
  (setq lsp-completion-provider :capf))

;; Use the Debug Adapter Protocol for running tests and debugging
(use-package posframe
  ;; Posframe is a pop-up tool that must be manually installed for dap-mode
  )
(use-package dap-mode
  :hook
  (lsp-mode . dap-mode)
  (lsp-mode . dap-ui-mode)
  )
