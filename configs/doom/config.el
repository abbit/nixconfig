;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

(setq default-frame-alist
      '((left . 170)
        (top . 20)
        (width . 150)
        (height . 50)))
(tool-bar-mode 0)

;; Terminal notifier
;; requires 'terminal-notifier' to be installed
(defvar terminal-notifier-command (executable-find "terminal-notifier") "The path to terminal-notifier.")

(defun terminal-notifier-notify (title message)
  "Show a message with terminal-notifier-command"
  (start-process "terminal-notifier"
                 "terminal-notifier"
                 terminal-notifier-command
                 "-title" title
                 "-message" message
                 "-sound" "default"
                 "-activate" "org.gnu.Emacs"))

;; (terminal-notifier-notify "Emacs notification" "Something amusing happened")

(defun timed-notification (time msg)
  (interactive "sNotification when (e.g: 2 minutes, 60 seconds, 3 days): \nsMessage: ")
  (run-at-time time nil (lambda (msg) (terminal-notifier-notify "Emacs" msg)) msg))

(setq org-show-notification-handler
      (lambda (msg) (timed-notification nil msg)))

;; enable notes after org-clock-out
(setq org-log-note-clock-out t)
(setq org-clock-clocktable-default-properties '(:maxlevel 4))

;; enable org-autolist-mode when in org-mode
(add-hook 'org-mode-hook (lambda () (org-autolist-mode)))

(setq org-agenda-prefix-format
      '((agenda . " %i %-12:c%?-12t% s%b")
        (timeline . "  % s")
        (todo . " %i %-12:c%b")
        (tags . " %i %-12:c")
        (search . " %i %-12:c")))


;; zen mode configuration
(setq +zen-text-scale 1.3)
(add-hook 'writeroom-mode-enable-hook (lambda () (display-line-numbers-mode -1)))
(add-hook 'writeroom-mode-disable-hook (lambda () (display-line-numbers-mode)))

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Mikhail Kopylov"
      user-mail-address "kopylovmichaelfl@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
(setq doom-font (font-spec :family "JetBrainsMono Nerd Font" :size 12)
      doom-big-font (font-spec :family "JetBrainsMono Nerd Font" :size 18))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-tomorrow-night)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")
(setq org-attach-id-dir "~/org/attachments")
;; (setq org-roam-directory "~/org/roam-notes")
;; (setq org-noter-default-notes-file-names '("book-notes.org") org-noter-notes-search-path '("~/org/books-notes"))

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

(setq projectile-project-search-path '("~/dev/"))

;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; (require 'org-inlinetask)

(use-package! org-super-agenda
  :after org-agenda
  :custom (org-super-agenda-groups
           '( ;; Each group has an implicit boolean OR operator between its selectors.
             (:name "Overdue" :deadline past :order 0)
             (:name "Due Today" :deadline today :order 1)
             (:name "Important"
              :and (:priority "A" :not (:todo ("DONE" "CANCELED")))
              :order 2)
             (:name "Today" ;; Optionally specify section name
              :time-grid t  ;; Items that appear on the time grid (scheduled/deadline with time)
              :order 3)     ;; capture the today first but show it in order 3
             (:name "Due Soon" :deadline future :order 4)
             (:name "Todo" :order 5)
             (:name "On Pause" :todo ("PAUSE") :order 9)))
  :config (setq org-super-agenda-header-map nil) (org-super-agenda-mode t))

(after! org
  (setq org-todo-keywords
      '((sequence "TODO(t)" "PROGRESS(p)" "PAUSE(s)" "|" "DONE(d)" "CANCELED(c)")))
  (setq org-todo-keyword-faces
      '(("PROGRESS" . (:foreground "orange1" :weight bold))
        ("PAUSE" . (:foreground "DarkSlateBlue"))
        ("CANCELED" . (:foreground "red")))))

(after! cider
  (set-popup-rules!
   '(("^\\*cider-repl"
      :side right
      :width 90
      :quit nil
      :ttl nil))))
