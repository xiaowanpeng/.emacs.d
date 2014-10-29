;color-theme
;slime
;auto-complete
;smex
;yasnippet
;w3m

(provide 'local_init)

(require 'color-theme)

(ispell-change-dictionary "american" t)

;color-theme
(color-theme-initialize)
(color-theme-charcoal-black)

;copy and paste with x-window
(setq x-select-enable-clipboard t)

;show line number
(linum-mode)

;use smex
(global-set-key (kbd "M-x") 'smex)

;hide tool bar
(menu-bar-showhide-tool-bar-menu-customize-disable)

;set background alpha
(set-frame-parameter (selected-frame) 'alpha (list 95 80))

;change window
(global-set-key [(control tab)] 'other-window)

;; vim O o 
(defun start-newline-next ()
  (interactive)
  (end-of-line)
  (newline-and-indent))

(defun start-newline-prev ()
  (interactive)
  (beginning-of-line)
  (newline)
  (forward-line -1))

(global-set-key (kbd "M-o") 'start-newline-prev)
(global-set-key (kbd "C-o") 'start-newline-next)

;;自定义的代码风格
(defconst my-c-style
'("stroustrup" ;;基于现有的代码风格进行修改。
    (c-offsets-alist . ((access-label . -)
                                 (inclass . ++)
                                 (case-label . +)
                                 (statement-case-intro . +))))
"My Programming Style")
;;将自定义的代码风格加入到列表中
(c-add-style "my" my-c-style)

(global-linum-mode 1)


;(setq inferior-lisp-program "/usr/bin/sbcl")
;(require 'slime)
;(slime-setup '(slime-fancy))

(global-set-key (kbd "RET") 'newline-and-indent)

(setq inferior-lisp-program "/usr/bin/lx86cl64 -K utf-8")
(require 'slime)
;(setq slime-net-coding-system 'utf-8-unix)
(slime-setup '(slime-fancy))

(setf common-lisp-hyperspec-root "/home/xiaowp/lisp/HyperSpec/")

;save desktop
;(load "desktop")
;(desktop-load-default)
;(desktop-read)
;;当emacs退出时保存文件打开状态
;(add-hook 'kill-emacs-hook
;          '(lambda()(desktop-save "~/")))

;cscope
(require 'xcscope)
(setq cscope-do-not-update-database t)

(define-key global-map [(control f3)]  'cscope-set-initial-directory)
(define-key global-map [(control f4)]  'cscope-unset-initial-directory)
(define-key global-map [(control f5)]  'cscope-find-this-symbol)
(define-key global-map [(control f6)]  'cscope-find-global-definition)
(define-key global-map [(control f7)]  'cscope-find-global-definition-no-prompting)
(define-key global-map [(control f8)]  'cscope-pop-mark)
(define-key global-map [(control f9)]  'cscope-next-symbol)
(define-key global-map [(control f10)] 'cscope-next-file)
(define-key global-map [(control f11)] 'cscope-prev-symbol)
(define-key global-map [(control f12)] 'cscope-prev-file)
(define-key global-map [(meta f9)]     'cscope-display-buffer)
(define-key global-map [(meta f10)]    'cscope-display-buffer-toggle)

;c++ mode style
(add-hook 'c++-mode-hook (lambda () (c-set-style "my")))

;hs-minor-mode
(add-hook 'c++-mode-hook 'hs-minor-mode)

(global-set-key (kbd "C-c t") 'hs-toggle-hiding)
;(global-set-key (kbd "C-c s") 'hs-show-all)
;(global-set-key (kbd "C-c h") 'hs-hide-all)

; yasnippet
(require 'yasnippet)
(yas-global-mode 1)

(global-auto-complete-mode)

(add-hook 'yas-before-expand-snippet-hook (lambda () (setq ac-auto-start nil)))
(add-hook 'yas-after-exit-snippet-hook (lambda () (setq ac-auto-start t)))


;set font
(set-fontset-font "fontset-default"
      'gb18030 '("WenQuanYi Micro Hei" . "unicode-bmp"))

(setq default-buffer-file-coding-system 'cn-gb-2312)

(setq browse-url-browser-function 'w3m)

(flyspell-mode-off)


;; point stack
;; modify on https://github.com/mattharrison/point-stack/blob/master/point-stack.el

(defvar point-stack nil)

(defvar cur-stack -1)

(defun cur-point-eql-stack-p ()
  (if (null point-stack)
      nil
      (let ((loc (nth cur-stack point-stack)))
        (if (and (eq (current-buffer) (car loc))
                 (eq (point) (cadr loc)))
            t nil))))

(defun point-create ()
  (setq point-stack
        (append (butlast point-stack (- (length point-stack) cur-stack 1))
                (list (list (current-buffer) (point) (window-start)))
                (last point-stack (- (length point-stack) cur-stack 1))))
  (setq cur-stack (+ cur-stack 1))
  (message "Location marked."))

(defun point-delete ()
  (setq point-stack
        (append (butlast point-stack (- (length point-stack) cur-stack))
                (last point-stack (- (length point-stack) cur-stack 1))))
  (setq cur-stack (- cur-stack 1))
  (message "Location unmarked."))
  
(defun point-create-or-delete ()
  (interactive)
  (if (cur-point-eql-stack-p)
      (point-delete)
      (point-create)))

(defun point-backward ()
  (interactive)
  (point-go (if (cur-point-eql-stack-p)
                (- cur-stack 1)
                cur-stack)))

(defun point-forward ()
  (interactive)
  (point-go (+ cur-stack 1)))

(defun point-go (idx)
  (cond ((< idx 0) (message "No backward."))
        ((>= idx (length point-stack)) (message "No forward."))
        (t (let ((loc (nth idx point-stack)))
             (switch-to-buffer (car loc))
             (set-window-start nil (caddr loc))
             (goto-char (cadr loc))
             (setq cur-stack idx)))))

(defun clear-point-stack ()
  (interactive)
  (setq point-stack nil)
  (setq cur-stack -1)
  (message "Point stack cleard."))

(global-set-key '[(f5)] 'point-create-or-delete)
(global-set-key '[(f6)] 'point-backward)
(global-set-key '[(f7)] 'point-forward)
(global-set-key '[(f8)] 'clear-point-stack)

(clear-point-stack)
;;; point-stack ends here

;;; ac-slime
;(require 'ac-slime)
;(add-hook 'slime-mode-hook 'set-up-slime-ac)
;(add-hook 'slime-repl-mode-hook 'set-up-slime-ac)
;(eval-after-load "auto-complete"
;  '(add-to-list 'ac-modes 'slime-repl-mode))

;;; paredit
(autoload 'enable-paredit-mode "paredit" "Turn on pseudo-structural editing of Lisp code." t)
(add-hook 'emacs-lisp-mode-hook       #'enable-paredit-mode)
(add-hook 'eval-expression-minibuffer-setup-hook #'enable-paredit-mode)
(add-hook 'ielm-mode-hook             #'enable-paredit-mode)
(add-hook 'lisp-mode-hook             #'enable-paredit-mode)
(add-hook 'lisp-interaction-mode-hook #'enable-paredit-mode)
(add-hook 'scheme-mode-hook           #'enable-paredit-mode)

(require 'eldoc) ; if not already loaded
(eldoc-add-command
 'paredit-backward-delete
 'paredit-close-round)

(add-hook 'slime-repl-mode-hook (lambda () (paredit-mode +1)))
;; Stop SLIME's REPL from grabbing DEL,
;; which is annoying when backspacing over a '('
(defun override-slime-repl-bindings-with-paredit ()
  (define-key slime-repl-mode-map
    (read-kbd-macro paredit-backward-delete-key) nil))
(add-hook 'slime-repl-mode-hook 'override-slime-repl-bindings-with-paredit)

(defvar electrify-return-match
  "[\]}\)\"]"
  "If this regexp matches the text after the cursor, do an \"electric\"
  return.")

(defun electrify-return-if-match (arg)
  "If the text after the cursor matches `electrify-return-match' then
  open and indent an empty line between the cursor and the text.  Move the
  cursor to the new line."
  (interactive "P")
  (let ((case-fold-search nil))
    (if (looking-at electrify-return-match)
        (save-excursion (newline-and-indent)))
    (newline arg)
    (indent-according-to-mode)))

;; Using local-set-key in a mode-hook is a better idea.
(global-set-key (kbd "RET") 'electrify-return-if-match)

(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            (paredit-mode t)
            (turn-on-eldoc-mode)
            (eldoc-add-command
             'paredit-backward-delete
             'paredit-close-round)
            (local-set-key (kbd "RET") 'electrify-return-if-match)
            (eldoc-add-command 'electrify-return-if-match)
            (show-paren-mode t)))
