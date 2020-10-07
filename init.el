;;; Emacs Settings
;;;; Keyboard Layout
(shell-command
 "setxkbmap -layout us -variant altgr-intl -option caps:escape")

;;;; Emacs UI
(menu-bar-mode -1)
(display-time-mode 1)
(scroll-bar-mode 0)
(tool-bar-mode -1)
(blink-cursor-mode 0)
(show-paren-mode 1)
(global-visual-line-mode t)
(fringe-mode 1)
(display-battery-mode t)

;;;; Emacs Misc
(setq-default tab-width 2)
(mouse-wheel-mode -1)
(setq show-paren-delay 0)

(setq help-at-pt-display-when-idle t)
(setq help-at-pt-timer-delay 0.1)
(help-at-pt-set-timer)

(setq backup-directory-alist `(("." . "~/.saves")))
(setq backup-by-copying t)
(setq delete-old-versions t
			kept-new-versions 4
			kept-old-versions 2
			version-control t)

(setq enable-recursive-minibuffers t)

(defalias 'yes-or-no-p 'y-or-n-p)

;;;; Font
(set-face-attribute 'default nil :font "deja vu sans mono 12")
(set-frame-font "deja vu sans mono 12" nil t)

;;;; Prefered Webbrowser
(setq browse-url-browser-function 'browse-url-generic
			browse-url-generic-program "qutebrowser")

;;;; Modeline
(defun modeline-alignment (left right)
	(let* ((available-width (-(window-width)(length left) 2)))
		(format (format "%%s %%%ds " available-width) left right)))

(setq battery-mode-line-format "%L %p %t")
(setq-default mode-line-format 'nil)
(setq-default header-line-format
							'((:eval (modeline-alignment
												;;left
												(format-mode-line
												 (list
													"   "
													;; Filestatus -:---
													mode-line-mule-info
													mode-line-modified
													mode-line-client
													mode-line-remote
													mode-line-front-space
													;; Buffername
													"%b"
													;; VC/Git
													'(vc-mode vc-mode)))
												;;right
												(format-mode-line
												 (list
													"%p%%"
													"  "
													;; Date (Week Year-Month-Day)
													'(:eval(propertize(format-time-string "w%V %a %d/%h")))
													;; Time (Hour:Minutes:Seconds)
													'(:eval(propertize(format-time-string "  %H:%M  ")))
													;; Battery Life
													;;(my/battery-modeline)
													battery-mode-line-string
													))))))

;;;; Line Numbers
(add-hook 'prog-mode-hook #'display-line-numbers-mode)

;;; Packages
;;;; Straight
(defvar bootstrap-version)
(let ((bootstrap-file
			 (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
			(bootstrap-version 5))
	(unless (file-exists-p bootstrap-file)
		(with-current-buffer
				(url-retrieve-synchronously
				 "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
				 'silent 'inhibit-cookies)
			(goto-char (point-max))
			(eval-print-last-sexp)))
	(load bootstrap-file nil 'nomessage))

;;;; Org-mode
(setq org-src-window-setup 'current-window)
(setq org-image-actual-width (* 15 (/ (window-width) 3)))

;;;;; Org-agenda
(global-set-key (kbd "s-a") 'org-agenda)
(setq org-agenda-start-on-weekday nil)
(setq org-agenda-span 30)

;;(org-agenda-files '("~/Documents/Todo/todolist.org"))

;;;; Evil
(straight-use-package 'evil)
(add-to-list 'load-path (concat user-emacs-directory "straight/build/undo-tree"))
(evil-mode)
(setq evil-emacs-state-modes nil)
(setq evil-insert-state-modes nil)
(setq evil-motion-state-modes nil)

(define-key evil-normal-state-map (kbd "C-u") (lambda ()
																								(interactive)
																								(evil-scroll-up nil)))
(define-key evil-normal-state-map (kbd "C-d") (lambda ()
																								(interactive)
																								(evil-scroll-down nil)))
(define-key evil-normal-state-map (kbd "Q") (lambda ()
																							(interactive)
																							(quit-window)))

;;;; Mouse-clicks
(dolist (mouseclicks-kill '([mouse-1] [down-mouse-1] [drag-mouse-1] [double-mouse-1] [triple-mouse-1]  
														[mouse-2] [down-mouse-2] [drag-mouse-2] [double-mouse-2] [triple-mouse-2]
														[mouse-3] [down-mouse-3] [drag-mouse-3] [double-mouse-3] [triple-mouse-3]
														[mouse-4] [down-mouse-4] [drag-mouse-4] [double-mouse-4] [triple-mouse-4]
														[mouse-5] [down-mouse-5] [drag-mouse-5] [double-mouse-5] [triple-mouse-5]))
  (global-unset-key mouseclicks-kill))
(define-key evil-motion-state-map [down-mouse-1] nil)

;;;; Dired
(add-hook 'dired-mode-hook
					(lambda ()
						(dired-hide-details-mode)))
;; Human readable memory listing
(setq dired-listing-switches "-alh")

;;;; Dired-du
;;(straight-use-package 'dired-du)
;;(setq dired-du-size-format t)

;;;; Undo-Tree
(straight-use-package 'undo-tree)
(global-undo-tree-mode)

;;;; Common-lisp
(require 'cl)

;;;; Hydra
;; https://github.com/abo-abo/hydra

(straight-use-package 'hydra)

;; | red      |                            |
;; | blue     | :exit t                    |
;; | amaranth | :foreign-keys warn         |
;; | teal     | :foreign-keys warn :exit t |
;; | pink     | :foreign-keys run          |

;;;;; Hydra-menu
(defhydra hydra-menu ()
	"Hydra Menu"
	("b" my/set-brightness "set-brightness" :exit t)
	("e" hydra-pulseaudio/body "hydra-pulseaudio" :exit t)
	("s-SPC" nil "quit" :exit t))

(global-set-key (kbd "s-SPC") 'hydra-menu/body)

;;;;; Hydra-window
(defhydra hydra-window ()
	("w" other-window "toggle")
	("c" delete-window "delete")
	("x" delete-other-windows "xor")
	("b" previous-buffer "prev")
	("s" split-window-below "split-below")
	("v" split-window-right "split-right")
	("0" balance-windows "balance")
	(")" balance-windows-area "area")
	("l" (enlarge-window-horizontally 5) "hor+")
	("h" (shrink-window-horizontally 5) "hor-")
	("k" (enlarge-window 5) "hor+")
	("j" (shrink-window 5) "hor-")
	("q" nil "quit" :exit t))

(global-set-key (kbd "s-w") 'hydra-window/body)
;;(evil-define-key 'normal 'evil-normal-state-map (kbd "s-w") 'hydra-window/body)

;;;;; Hydra-pulseaudio
(defhydra hydra-pulseaudio ()
	"pulseaudio-menu"
	("-" pulseaudio-control-decrease-volume "dec -10")
	("=" pulseaudio-control-increase-volume "inc +10")
	("_" pulseaudio-control-select-sink-by-name "select sink")
	("+" pulseaudio-control-toggle-current-sink-mute "mute sink")
	("b" hydra-menu/body "back" :exit t)
	("s-SPC" nil "quit" :exit t))

;;;; Ivy
(straight-use-package 'ivy)
(add-hook 'after-init-hook 'ivy-mode)
(setq ivy-use-virtual-buffers t)
(setq enable-recursive-minibuffers t)

;;;;; Counsel
(straight-use-package 'counsel)
(counsel-mode)
(global-set-key (kbd "M-x") 'counsel-M-x)
;;(global-set-key (kbd "C-x d") 'counsel-dired)
;;(global-set-key (kbd "C-x b") 'switch-to-buffer)
(global-set-key (kbd "C-x d") 'counsel-find-file)
(global-set-key (kbd "<f1> f") 'counsel-describe-function)
(global-set-key (kbd "<f1> v") 'counsel-describe-variable)
(global-set-key (kbd "<f1> l") 'counsel-find-library)
(global-set-key (kbd "<f2> i") 'counsel-info-lookup-symbol)
(global-set-key (kbd "<f2> u") 'counsel-unicode-char)

;;;;; Swiper
(straight-use-package 'swiper)
(global-set-key (kbd "\C-s") 'swiper)

;;;; Avy
(straight-use-package 'avy)

;;;; Vterm
;;(straight-use-package 'vterm)

;;;; Which Key
(straight-use-package 'which-key)
(which-key-mode)
(setq which-key-show-prefix 'left)

;;;; Colorschemes

;;;;; Spacemacs Theme
(straight-use-package 'spacemacs-theme)
(load-theme 'spacemacs-dark t)

;;;; Outshine
(straight-use-package 'outshine)
(add-hook 'emacs-lisp-mode-hook 'outshine-mode)

;;;; Org-brain
(straight-use-package 'org-brain)
(setq org-brain-path "~/Documents/OrgBrain")
(setq org-brain-show-history nil)
(setq org-brain-show-resources nil)
(setq org-brain-open-same-window t)

(global-set-key (kbd "s-b") 'org-brain-visualize)

;;(with-eval-after-load 'evil
;;(evil-set-initial-state 'org-brain-visualize-mode 'emacs))

;; headline entries only
;;(setq org-brain-include-file-entries nil
;;org-brain-file-entries-use-title nil
;;org-brain-headline-entry-name-format-string "%2$s")
;;(add-hook 'before-save-hook #'org-brain-ensure-ids-in-buffer)

;; file entries only
;;(setq org-brain-scan-for-header-entries nil)


(setq org-brain-completion-system 'ivy)

(with-eval-after-load 'org
	(require 'org-brain))

(add-hook 'org-brain-visualize-text-hook 'org-toggle-latex-fragment)
(add-hook 'org-brain-visualize-text-hook 'org-toggle-inline-images)

;;;; Code Completion Engines

;;;;; Yasnippet
(straight-use-package 'yasnippet)
(add-to-list 'load-path
						 "~/.emacs.d/plugins/yasnippet")
(yas-global-mode 1)

;;;;; Company
(straight-use-package 'company)
(add-hook 'after-init-hook 'global-company-mode)

;;;;; Company-lsp
(straight-use-package 'company-lsp)
(require 'company-lsp)
(push 'company-lsp company-backends)
(setq company-lsp-cache-candidates t)
(setq company-lsp-async t)
(setq company-lsp-enable-snippet t)

;;;; Magit
(straight-use-package 'magit)

;;;;; Keybinds
(require 'evil)
(evil-define-key 'normal 'evil-normal-state-map
	(kbd "C-x g") 'magit-status)
(evil-define-key 'normal magit-mode-map
	(kbd "j") 'magit-section-forward
	(kbd "k") 'magit-section-backward
	(kbd "p") 'magit-pull
	(kbd "s") 'magit-stage-file
	(kbd "u") 'magit-unstage-file
	(kbd "c") 'magit-commit
	(kbd "m") 'magit-merge
	(kbd "P") 'magit-push
	(kbd "f") 'magit-fetch
	(kbd "l") 'magit-log
	(kbd "i") 'magit-gitignore
	(kbd "r") 'magit-refresh
	(kbd "g") 'beginning-of-buffer
	(kbd "G") 'end-of-buffer
	(kbd "M") 'magit-remote
	(kbd "d") 'magit-diff
	(kbd "b") 'magit-branch
	(kbd "R") 'magit-reset
	(kbd "Q") 'magit-mode-bury-buffer)

;;;; Org-bullets
(straight-use-package 'org-bullets)
(defun org-bullet-mode()
	(org-bullets-mode 1))
(add-hook 'org-mode-hook 'org-bullet-mode)

;;;; Aggressive Indent
(straight-use-package 'aggressive-indent)
(add-hook 'emacs-lisp-mode-hook #'aggressive-indent-mode)

;;;; Pdf-tools
(straight-use-package 'pdf-tools)
(pdf-tools-install)
(add-to-list 'auto-mode-alist '("\\.pdf\\'" . pdf-view-mode))

;;;;; Keybinds
(require 'evil)
(evil-define-key 'normal pdf-view-mode-map
	(kbd "j") 'pdf-view-scroll-up-or-next-page
	(kbd "k") 'pdf-view-scroll-down-or-previous-page
	(kbd "C-j") 'pdf-view-next-line-or-next-page
	(kbd "C-k") 'pdf-view-previous-line-or-previous-page
	(kbd "J") 'pdf-view-next-page-command
	(kbd "K") 'pdf-view-previous-page-command
	(kbd "h") 'image-backward-hscroll
	(kbd "l") 'image-forward-hscroll
	(kbd "f") 'pdf-view-goto-page
	(kbd "r") 'pdf-view-revert-buffer
	(kbd "=") 'pdf-view-enlarge
	(kbd "+") 'pdf-view-enlarge
	(kbd "-") 'pdf-view-shrink
	(kbd "0") 'pdf-view-scale-reset
	(kbd "H") 'pdf-view-fit-height-to-window
	(kbd "W") 'pdf-view-fit-width-to-window
	(kbd "P") 'pdf-view-fit-page-to-window
	(kbd "/") 'isearch-forward-word
	(kbd "n") 'isearch-repeat-forward
	(kbd "N") 'isearch-repeat-backward
	(kbd "G") 'pdf-view-first-page
	(kbd "o") 'pdf-outline)

;;;; Rainbow Delimiters
(straight-use-package 'rainbow-delimiters)
(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)

;;;; Gnuplot
(straight-use-package 'gnuplot)
;;;; Ox-twbs
(straight-use-package 'ox-twbs)

;;;; Smartparens
(straight-use-package 'smartparens)
(require 'smartparens-config)
(add-hook 'org-mode-hook #'smartparens-mode)
(add-hook 'prog-mode-hook #'smartparens-mode)
;;(sp-local-pair 'c-mode "'" nil :actions :rem)
;;(sp-local-pair 'c-mode "'" "'")
(sp-local-pair 'emacs-lisp-mode "`" "'")
(setq-default sp-escape-quotes-after-insert nil)
;;Symbol's function definition is void: sp-local-pair

;;;; Flycheck
(straight-use-package 'flycheck)
(global-flycheck-mode)
(with-eval-after-load 'flycheck
	(setq-default flycheck-disabled-checkers '(emacs-lisp-checkdoc)))

;;;; LSP-mode
(straight-use-package 'lsp-mode)
(require 'lsp-mode)
(add-hook 'lsp-mode-hook #'lsp)
(add-hook 'c-mode-hook #'lsp)
(add-hook 'java-mode-hook #'lsp)

;;;;; Dap-mode
(straight-use-package 'dap-mode)
(dap-mode 1)
(dap-ui-mode 1)
(dap-tooltip-mode 1)
(tooltip-mode 1)

;;;;; CCLS
(with-eval-after-load 'lsp
	(straight-use-package 'ccls)
	(require 'ccls)
	(setq ccls-executable "/usr/bin/ccls")
	(add-hook 'c-mode-hook #'lsp))

;;;;; LSP-java
(with-eval-after-load 'lsp
	(straight-use-package 'lsp-java)
	(require 'dap-java)
	(require 'lsp-java))


;;;; Exwm
(straight-use-package 'exwm)
(server-start)
(require 'exwm)

(setq exwm-workspace-number 4)
(setq ediff-window-setup-function 'ediff-setup-window-plain)

(add-hook 'exwm-update-class-hook
					(lambda ()
						(unless (or (string-prefix-p "sun-awt-X11-" exwm-instance-name)
												(string= "gimp" exwm-instance-name))
							(exwm-workspace-rename-buffer exwm-class-name))))
(add-hook 'exwm-update-title-hook
					(lambda ()
						(when (or (not exwm-instance-name)
											(string-prefix-p "sun-awt-X11-" exwm-instance-name)
											(string= "gimp" exwm-instance-name))
							(exwm-workspace-rename-buffer exwm-title))))

(setq exwm-input-global-keys
			`(
				;; [s-r] Exit char-mode and fullscreen mode
				([?\s-r] . exwm-reset)
				;; [s-w] Switch workspace interactively
				([?\s-w] . exwm-workspace-switch)
				;; [s-%d] Switch to a workspace by its index
				,@(mapcar (lambda (i)
										`(,(kbd (format "s-%d" i)) .
											(lambda ()
												(interactive)
												(exwm-workspace-switch-create ,i))))
									(number-sequence 0 9))
				;; [s-&][M-&] Launch applications 
				([?\s-&] . (lambda (command)
										 (interactive (list (read-shell-command "$ ")))
										 (start-process-shell-command command nil command)))
				;; Bind "s-<f2>" to start mupdf on this pdf file
				([s-f2] . (lambda ()
										(interactive)
										(start-process "" nil "/usr/bin/mupdf" (f-this-file))))))

(define-key exwm-mode-map [?\C-q] #'exwm-input-send-next-key)
(define-key exwm-mode-map [?\s-c] #'exwm-input-release-keyboard)
(define-key exwm-mode-map [?\s-f] #'exwm-layout-toggle-fullscreen)
(define-key exwm-mode-map [?\C-w ?\C-w] #'evil-window-next)
(define-key exwm-mode-map [?\C-w ?\C-s] #'evil-window-split)
(define-key exwm-mode-map [?\C-w ?\C-v] #'evil-window-vsplit)
(define-key exwm-mode-map [?\C-w ?\C-c] #'evil-window-delete)
(define-key exwm-mode-map [?\s-\ ] #'hydra-menu/body)

(evil-set-initial-state 'exwm-mode 'emacs)
(setq exwm-input-simulation-keys
			'(
				;; movement
				([?\C-u] . [prior])
				([?\C-d] . [next])))

(defun exwm-passthrough (orig-fun keymap on-exit &optional foreign-keys)
	(setq exwm-input-line-mode-passthrough t)
	(let ((on-exit (lexical-let ((on-exit on-exit))
									 (lambda ()
										 (setq exwm-input-line-mode-passthrough nil)
										 (when on-exit (funcall on-exit))))))
		(apply orig-fun keymap on-exit (list foreign-keys))))

(advice-add 'hydra-set-transient-map :around #'exwm-passthrough)

(require 'exwm-randr)
(exwm-randr-enable)
(exwm-enable)

;;;; My/set-brightness
(defun my/set-brightness()
	(interactive)
	(setq my/max-brightness-file "/sys/class/backlight/intel_backlight/max_brightness")
	(setq my/brightness-file "/sys/class/backlight/intel_backlight/brightness")

	(let* ((my/max-brightness
					(string-to-number(f-read-text my/max-brightness-file)))
				 (my/brightness-ratio
					(/ (string-to-number(read-from-minibuffer "Brightness 0-100: ")) 100.0))
				 (my/brightness
					(floor(* my/max-brightness my/brightness-ratio))))
		(shell-command
		 (concat "echo " (number-to-string my/brightness) " > " my/brightness-file))))

;;;; Pulseaudio-control
(straight-use-package 'pulseaudio-control)

;;;; ScreenShot
(straight-use-package 'screenshot)
(global-set-key (kbd "s-p") 'screenshot)
(setq screenshot-schemes
			'(
				("local"
				 :dir "~/Media/Screenshots")
				("current-dir"
				 :dir default-directory)))

;;;; Randr-config
(defun generate-randr-config (primary secondary)
  (-flatten `(,(-map (lambda (n) (list n primary)) (number-sequence 1 7))
              (0 secondary)
              ,(-map (lambda (n) (list n secondary)) (number-sequence 8 9)))))

(defun randr-layout-dp1-extend ()
	"Extend the screen to Display Port"

  (interactive)
  (setq exwm-randr-workspace-monitor-plist (generate-randr-config "DP-1" "eDP-1"))
  (exwm-randr-refresh)
	(randr-layout-single)
  (shell-command "xrandr --output DP-1 --left-of eDP-1 --auto --primary"))

(defun randr-layout-hdmi1-extend ()
	"Extend the screen to HDMI"

  (interactive)
  (setq exwm-randr-workspace-monitor-plist (generate-randr-config "HDMI-1" "eDP-1"))
  (exwm-randr-refresh)
	(randr-layout-single)
	(shell-command "xrandr --output HDMI-1 --auto --left-of eDP-1 --auto --primary"))

(defun randr-layout-hdmi1-only ()
	"Only HDMI is shown"

	(interactive)
	(exwm-randr-refresh)
	(shell-command "xrandr --output HDMI-1 --auto --primary")
	(shell-command "xrandr --output eDP-1 --off"))

(defun randr-layout-dp1-only ()
	"Only HDMI is shown"

	(interactive)
	(exwm-randr-refresh)
	(shell-command "xrandr --output DP-1 --auto --primary")
	(shell-command "xrandr --output eDP-1 --off"))

(defun randr-layout-single ()
	"Laptop screen only!"

	(interactive)
	(exwm-randr-refresh)
	(shell-command "xrandr --output eDP-1 --auto --primary")
	(shell-command "xrandr --output HDMI-1 --off")
	(shell-command "xrandr --output DP-1 --off"))

;; xrandr multiple monitor
;;(setq exwm-randr-workspace-output-plist '(1 "DP-1" 2 "DP-2"))
;;(add-hook 'exwm-randr-screen-change-hook
;;(lambda ()
;;(start-process-shell-command
;;"xrandr" nil "xrandr --output DP-1 --right-of LVDS1 --auto")))

;;;; Ido-mode
(ido-mode -1)
(defun ido-mode (&optional rest)
	())

;;;; Libvterm
	(setq load-path (append load-path (file-expand-wildcards (expand-file-name "~/.nix-profile/share/emacs/site-lisp/elpa/*"))))
(load-library "vterm-autoloads")
