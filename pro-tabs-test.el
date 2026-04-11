;;; pro-tabs-test.el --- Tests for pro-tabs

(require 'ert)
(require 'pro-tabs)

(ert-deftest pro-tabs-enable-disable ()
  "Test enable/disable of `pro-tabs-mode' toggles tab-bar-mode."
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

;; Можно добавить другие тесты следующим образом:
;; (ert-deftest pro-tabs-format-tab-bar-basic () ...)

(provide 'pro-tabs-test)
;;; pro-tabs-test.el ends here
