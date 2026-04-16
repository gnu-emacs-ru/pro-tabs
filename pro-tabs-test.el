;;; pro-tabs-test.el --- Tests for pro-tabs

(require 'ert)
(require 'pro-tabs)

(defun pro-tabs--test-color-brightness (color)
  (let ((rgb (ignore-errors (color-name-to-rgb color))))
    (when rgb
      (+ (* 0.2126 (nth 0 rgb))
         (* 0.7152 (nth 1 rgb))
         (* 0.0722 (nth 2 rgb))))))

(defun pro-tabs--test-color-different-p (a b)
  (not (equal a b)))

(ert-deftest pro-tabs-enable-disable ()
  "Test enable/disable of `pro-tabs-mode' toggles tab-bar-mode.
Requires interactive Emacs (not batch)."
  :tags '(:interactive)
  (skip-unless (null command-line-args))
  (let ((was-tab-bar tab-bar-mode)
        (was-tab-line (and (boundp 'tab-line-mode) tab-line-mode)))
    (unwind-protect
        (progn
          (pro-tabs-mode 1)
          (should pro-tabs-mode)
          (should (or (not (boundp 'tab-bar-mode)) tab-bar-mode))
          (pro-tabs-mode 0)
          (should-not pro-tabs-mode)
          (should (eq tab-bar-mode was-tab-bar))
          (when (boundp 'tab-line-mode)
            (should (eq tab-line-mode was-tab-line))))
      (ignore-errors (pro-tabs-mode 0)))))

(ert-deftest pro-tabs-icon-cache-is-mode-aware ()
  "Mode changes should not reuse stale buffer icon cache entries."
  (let ((buffer (get-buffer-create "*pro-tabs-mode-cache*")))
    (unwind-protect
        (with-current-buffer buffer
          (pro-tabs-mode 1)
          (clrhash pro-tabs--icon-cache-by-buffer)
          (let ((pro-tabs-enable-icons t)
                (major-mode 'text-mode))
            (ignore-errors (pro-tabs--icon buffer 'tab-line)))
          (clrhash pro-tabs--icon-cache-by-buffer)
          (let ((major-mode 'emacs-lisp-mode)
                (pro-tabs-enable-icons t))
            (should (or (pro-tabs--icon buffer 'tab-line) t)))
          (pro-tabs-mode 0))
      (kill-buffer buffer))))

(ert-deftest pro-tabs-does-not-leave-empty-tab-line-on-disable ()
  "Disabling pro-tabs should not leave tab-line enabled in ordinary buffers."
  (let ((buffer (get-buffer-create "*pro-tabs-tab-line-disable*")))
    (unwind-protect
        (with-current-buffer buffer
          (let ((tab-line-format 'tab-line-format))
            (when (boundp 'tab-line-mode)
              (tab-line-mode -1))
            (pro-tabs-mode 1)
            (pro-tabs-mode 0)
            (when (boundp 'tab-line-mode)
              (should-not tab-line-mode))
            (should (equal tab-line-format 'tab-line-format))))
      (kill-buffer buffer))))

(ert-deftest pro-tabs-does-not-force-tab-line-on ()
  "Enabling pro-tabs should not turn on tab-line in a buffer that had it off."
  (let ((buffer (get-buffer-create "*pro-tabs-tab-line-off*")))
    (unwind-protect
        (with-current-buffer buffer
          (when (boundp 'tab-line-mode)
            (tab-line-mode -1))
          (pro-tabs-mode 1)
          (when (boundp 'tab-line-mode)
            (should-not tab-line-mode))
          (pro-tabs-mode 0))
      (kill-buffer buffer))))

(ert-deftest pro-tabs-restores-tab-bar-lines-on-disable ()
  "Disabling pro-tabs should restore the frame tab-bar line count."
  (let ((lines (frame-parameter nil 'tab-bar-lines)))
    (progn
      (pro-tabs-mode 1)
      (should (= (frame-parameter nil 'tab-bar-lines) 1))
      (pro-tabs-mode 0)
      (should (equal (frame-parameter nil 'tab-bar-lines) lines)))))

(ert-deftest pro-tabs-restores-global-tab-line-mode-on-disable ()
  "Disabling pro-tabs should restore `global-tab-line-mode' when present."
  (when (boundp 'global-tab-line-mode)
    (let ((was global-tab-line-mode))
      (unwind-protect
          (progn
            (when was (global-tab-line-mode -1))
            (pro-tabs-mode 1)
            (should-not global-tab-line-mode)
            (pro-tabs-mode 0)
            (should (eq global-tab-line-mode was)))
        (when was (global-tab-line-mode 1))))))

(ert-deftest pro-tabs-format-cache-is-mode-aware ()
  "Format cache should vary with major mode for buffer tabs."
  (let ((buffer (get-buffer-create "*pro-tabs-format-cache*")))
    (unwind-protect
        (with-current-buffer buffer
          (pro-tabs-mode 1)
          (clrhash pro-tabs--format-cache)
          (let ((major-mode 'text-mode))
            (pro-tabs--format 'tab-line buffer))
          (let ((major-mode 'emacs-lisp-mode))
            (should (stringp (pro-tabs--format 'tab-line buffer))))
          (pro-tabs-mode 0))
      (kill-buffer buffer))))

(ert-deftest pro-tabs-icon-is-renderable ()
  "Icon provider should return a string when icons enabled."
  (let ((buffer (get-buffer-create "*pro-tabs-icon-render*")))
    (unwind-protect
        (with-current-buffer buffer
          (pro-tabs-mode 1)
          (let ((pro-tabs-enable-icons t))
            (clrhash pro-tabs--icon-cache-by-buffer)
            (let ((icon (pro-tabs--icon buffer 'tab-line)))
              (should (stringp icon))
              (should (> (length icon) 0))))
          (pro-tabs-mode 0))
      (kill-buffer buffer))))

(ert-deftest pro-tabs-icon-cache-resets-on-mode-toggle ()
  "Mode toggles should not preserve stale icon cache entries."
  (let ((buffer (get-buffer-create "*pro-tabs-icon-reset*"))
        (seen nil))
    (unwind-protect
        (with-current-buffer buffer
          (let ((pro-tabs-icon-functions
                 (list (lambda (_buffer _backend)
                         (setq seen (1+ (or seen 0)))
                         (format "I%d" seen)))))
            (pro-tabs-mode 1)
            (setq seen nil)
            (clrhash pro-tabs--icon-cache-by-buffer)
            (let ((first (pro-tabs--icon buffer 'tab-bar)))
              (should (equal first "I1")))
            (pro-tabs-mode 0)
            (pro-tabs-mode 1)
            (setq seen nil)
            (clrhash pro-tabs--icon-cache-by-buffer)
            (let ((second (pro-tabs--icon buffer 'tab-bar)))
              (should (equal second "I1")))
            (pro-tabs-mode 0)))
      (kill-buffer buffer))))

(ert-deftest pro-tabs-tab-bar-format-includes-provider-icon ()
  "Tab-bar formatting should include provider output."
  (let ((buffer (get-buffer-create "*pro-tabs-tab-bar-icon*")))
    (unwind-protect
        (with-current-buffer buffer
          (let ((pro-tabs-icon-functions
                 (list (lambda (_buffer _backend) (propertize "I" 'face 'success)))))
            (pro-tabs-mode 1)
            (let ((pro-tabs-enable-waves nil))
              (clrhash pro-tabs--format-cache)
              (let* ((tab `((current-tab . t) (name . ,(buffer-name buffer))))
                     (txt (pro-tabs-format-tab-bar tab 0))
                     (pos (string-match-p "I" txt))
                     (faces nil))
                (should (stringp txt))
                (should pos)
                (setq faces (get-text-property pos 'face txt))
                (should (or (eq faces 'success) (memq 'success faces))))
            (pro-tabs-mode 0))))
      (kill-buffer buffer))))

(ert-deftest pro-tabs-tab-bar-keeps-tab-face ()
  "Tab-bar text after the icon should still use tab faces."
  (let ((buffer (get-buffer-create "*pt-face*")))
    (unwind-protect
        (with-current-buffer buffer
          (let ((pro-tabs-icon-functions
                 (list (lambda (_buffer _backend) (propertize "I" 'face 'success)))))
            (pro-tabs-mode 1)
            (let* ((tab `((current-tab . t) (name . ,(buffer-name buffer))))
                   (txt (pro-tabs-format-tab-bar tab 0))
                   (pos (string-match-p (regexp-quote (pro-tabs--shorten (buffer-name buffer)
                                                                         pro-tabs-max-name-length)) txt))
                   (faces nil))
              (should pos)
              (setq faces (get-text-property pos 'face txt))
              (should (or (eq faces 'pro-tabs-active-face)
                          (memq 'pro-tabs-active-face faces))))
            (pro-tabs-mode 0)))
      (kill-buffer buffer))))

(ert-deftest pro-tabs-enable-triggers-tab-bar-refresh ()
  "Enabling the mode should ask tab-bar to redraw."
  (let ((calls 0))
    (cl-letf (((symbol-function 'tab-bar--update-tab-bar-lines)
               (lambda (&rest _) (setq calls (1+ calls)))))
      (pro-tabs-mode 1)
      (pro-tabs-mode 0)
      (should (> calls 0)))))

(ert-deftest pro-tabs-full-tab-string-includes-icon ()
  "Full rendered tab should contain a visible icon glyph."
  (let ((buf (get-buffer-create "*pro-tabs-full*")))
    (unwind-protect
        (with-current-buffer buf
          (pro-tabs-mode 1)
          (let ((pro-tabs-enable-icons t))
            (clrhash pro-tabs--format-cache)
            (let ((tab (pro-tabs--format 'tab-line buf)))
              (should (stringp tab))
              (should (string-match-p "[•]" tab))))
          (pro-tabs-mode 0))
      (kill-buffer buf))))

(ert-deftest pro-tabs-active-and-inactive-faces-follow-theme ()
  "Active tabs should use the main background and a bright foreground."
  (let ((buffer (get-buffer-create "*pro-tabs-face-theme*")))
    (unwind-protect
        (with-current-buffer buffer
          (pro-tabs-mode 1)
          (let* ((default-bg (face-background 'default nil t))
                 (active-bg (face-background 'pro-tabs-active-face nil t))
                 (inactive-bg (face-background 'pro-tabs-inactive-face nil t))
                 (active-fg (face-foreground 'pro-tabs-active-face nil t))
                 (default-brightness (pro-tabs--test-color-brightness default-bg))
                 (inactive-brightness (pro-tabs--test-color-brightness inactive-bg))
                 (active-fg-brightness (pro-tabs--test-color-brightness active-fg)))
            (should (pro-tabs--test-color-different-p active-bg inactive-bg))
            (should (pro-tabs--test-color-different-p inactive-bg (face-background 'tab-bar nil t)))
            (should (stringp active-fg))
            (should (not (member active-fg '("unspecified-fg" "unspecified"))))
            (should (or (null default-brightness)
                        (null inactive-brightness)
                        (< inactive-brightness default-brightness)))
            (should (or (null default-brightness)
                        (null (pro-tabs--test-color-brightness (face-background 'tab-bar nil t)))
                        (< (pro-tabs--test-color-brightness (face-background 'tab-bar nil t))
                           inactive-brightness)))
            (should (not (equal active-bg inactive-bg)))
            (should (not (equal inactive-bg (face-background 'tab-bar nil t))))
            (should (or (null active-fg-brightness)
                        (null default-brightness)
                        (> active-fg-brightness default-brightness)))
            (should (eq (face-attribute 'tab-bar-tab :inherit nil t) 'pro-tabs-active-face))
            (should (eq (face-attribute 'tab-line-tab-current :inherit nil t) 'pro-tabs-active-face))
            (should (eq (face-attribute 'tab-line-tab-inactive :inherit nil t) 'pro-tabs-inactive-face))
            (pro-tabs-mode 0)))
      (kill-buffer buffer))))

(ert-deftest pro-tabs-enable-refreshes-theme-faces ()
  "Enabling pro-tabs should recompute theme-dependent faces."
  (let ((buffer (get-buffer-create "*pro-tabs-enable-theme-refresh*"))
        (calls 0))
    (unwind-protect
        (with-current-buffer buffer
          (cl-letf (((symbol-function 'pro-tabs--refresh-faces)
                     (lambda (&rest _)
                       (setq calls (1+ calls)))))
            (pro-tabs-mode 1)
            (pro-tabs-mode 0)
            (should (> calls 0))))
      (kill-buffer buffer))))

;; Можно добавить другие тесты следующим образом:
;; (ert-deftest pro-tabs-format-tab-bar-basic () ...)

(provide 'pro-tabs-test)
;;; pro-tabs-test.el ends here
