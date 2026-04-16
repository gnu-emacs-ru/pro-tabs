;;; pro-tabs-e2e-test.el --- E2E tests for pro-tabs

(require 'ert)
(require 'pro-tabs)

(defun pro-tabs-e2e--with-icon-stub (fn)
  (let ((pro-tabs-icon-functions
         (list (lambda (_buffer _backend)
                 (propertize "I" 'face 'success)))))
    (funcall fn)))

;; Try to load all-the-icons if available.
(ignore-errors (require 'all-the-icons nil t))

(ert-deftest pro-tabs-e2e-enable-renders-tab-line-and-bar ()
  "Enable the mode and verify core rendering entry points are usable."
  (let ((buffer (get-buffer-create "*pro-tabs-e2e*")))
    (unwind-protect
        (with-current-buffer buffer
          (pro-tabs-mode 1)
          (should (functionp tab-bar-tab-name-format-function))
          (should (functionp tab-line-tabs-function))
          (should (functionp tab-line-tab-name-function))
          (should (stringp (pro-tabs-format-tab-bar '(current-tab (name . "*pro-tabs-e2e*")) 0)))
          (should (stringp (pro-tabs-format-tab-line buffer nil)))
          (pro-tabs-mode 0))
      (kill-buffer buffer))))

(ert-deftest pro-tabs-e2e-icons-available ()
  "Verify all-the-icons package is loaded and fonts are available."
  (when (featurep 'all-the-icons)
    (should (or (and (fboundp 'all-the-icons-fontawesome-p) (all-the-icons-fontawesome-p))
                (and (fboundp 'all-the-icons-material-p) (all-the-icons-material-p))
                (and (fboundp 'all-the-icons-octicons-p) (all-the-icons-octicons-p))
                (and (fboundp 'all-the-icons-alltheicons-p) (all-the-icons-alltheicons-p))))))

(ert-deftest pro-tabs-e2e-icon-provider-returns-icon ()
  "Test that icon provider returns a proper icon string."
  (let ((buf (get-buffer-create "*pro-tabs-e2e-icon*")))
    (unwind-protect
        (with-current-buffer buf
          (pro-tabs-e2e--with-icon-stub
           (lambda ()
             (let ((icon (pro-tabs--icon buf 'tab-bar)))
               (should (stringp icon))
               (should (equal icon (propertize "I" 'face 'success)))))))
      (kill-buffer buf))))

(ert-deftest pro-tabs-e2e-tab-bar-keeps-icon-face ()
  "Tab-bar formatting should preserve icon-specific face properties."
  (let ((buf (get-buffer-create "*pro-tabs-e2e-tab-bar-face*")))
    (unwind-protect
        (with-current-buffer buf
          (let ((pro-tabs-icon-functions
                 (list (lambda (_buffer _backend) (propertize "I" 'face 'success))))
                (pro-tabs-enable-waves nil))
            (pro-tabs-mode 1)
            (let* ((tab `((current-tab . t) (name . ,(buffer-name buf))))
                   (txt (pro-tabs-format-tab-bar tab 0)))
              (should (stringp txt))
              (let ((pos (string-match-p "I" txt)))
                (should pos)
                (should (memq 'success (if (listp (get-text-property pos 'face txt))
                                           (get-text-property pos 'face txt)
                                         (list (get-text-property pos 'face txt)))))))
            (pro-tabs-mode 0)))
      (kill-buffer buf))))

(ert-deftest pro-tabs-e2e-tab-bar-keeps-tab-face ()
  "Tab-bar formatting should keep the tab face on the label text."
  (let ((buf (get-buffer-create "*pt-e2e-face*")))
    (unwind-protect
        (with-current-buffer buf
          (let ((pro-tabs-icon-functions
                 (list (lambda (_buffer _backend) (propertize "I" 'face 'success)))))
            (pro-tabs-mode 1)
            (let* ((tab `((current-tab . t) (name . ,(buffer-name buf))))
                   (txt (pro-tabs-format-tab-bar tab 0))
                    (pos (string-match-p (regexp-quote (pro-tabs--shorten (buffer-name buf)
                                                                           pro-tabs-max-name-length)) txt))
                   (faces nil))
              (should pos)
              (setq faces (get-text-property pos 'face txt))
              (should (or (eq faces 'pro-tabs-active-face)
                          (memq 'pro-tabs-active-face faces))))
            (pro-tabs-mode 0)))
      (kill-buffer buf))))

(ert-deftest pro-tabs-e2e-tab-bar-refreshes-with-new-icon-provider ()
  "Tab-bar should pick up a new icon provider after re-enable."
  (let ((buf (get-buffer-create "*pro-tabs-e2e-refresh*"))
        (phase 0)
        (glyph "⊙"))
    (unwind-protect
        (with-current-buffer buf
          (let ((pro-tabs-icon-functions
                 (list (lambda (_buffer _backend)
                         (and (= phase 1)
                              (propertize glyph 'face 'success))))))
            (pro-tabs-mode 1)
            (clrhash pro-tabs--format-cache)
            (let* ((tab `((current-tab . t) (name . ,(buffer-name buf))))
                   (txt1 (pro-tabs-format-tab-bar tab 0)))
              (should (not (string-match-p (regexp-quote glyph) txt1))))
            (pro-tabs-mode 0)
            (setq phase 1)
            (pro-tabs-mode 1)
            (clrhash pro-tabs--format-cache)
            (let* ((tab `((current-tab . t) (name . ,(buffer-name buf))))
                   (txt2 (pro-tabs-format-tab-bar tab 0)))
              (should (string-match-p (regexp-quote glyph) txt2)))
            (pro-tabs-mode 0)))
      (kill-buffer buf))))

(ert-deftest pro-tabs-e2e-enable-refreshes-tab-bar ()
  "Enabling pro-tabs should request a tab-bar redraw."
  (let ((calls 0))
    (cl-letf (((symbol-function 'tab-bar--update-tab-bar-lines)
               (lambda (&rest _) (setq calls (1+ calls)))))
      (pro-tabs-mode 1)
      (pro-tabs-mode 0)
      (should (> calls 0)))))

(ert-deftest pro-tabs-e2e-icon-provider-fallback ()
  "Test icon fallback when mode not matched."
  (let ((buf (get-buffer-create "*pro-tabs-e2e-fallback*")))
    (unwind-protect
        (with-current-buffer buf
          (setq major-mode 'fundamental-mode)
          (let ((icon (pro-tabs--icon buf 'tab-bar)))
            (should (stringp icon))
            (should (> (length icon) 0))))
      (kill-buffer buf))))

(ert-deftest pro-tabs-e2e-tab-line-shows-only-with-multiple-buffers ()
  "Test that tab-line is only trimmed when it is already enabled."
  (let ((buf1 (get-buffer-create "*pro-tabs-test-1*"))
        (buf2 (get-buffer-create "*pro-tabs-test-2*"))
        (mode1 (make-symbol "pro-tabs-test-mode-1"))
        (mode2 (make-symbol "pro-tabs-test-mode-2")))
    (unwind-protect
        (progn
          (with-current-buffer buf1
            (setq-local major-mode mode1)
            (pro-tabs-mode 1)
            (when (boundp 'tab-line-mode)
              (should-not tab-line-mode)))
          (with-current-buffer buf2
            (setq-local major-mode mode2)
            (pro-tabs-mode 1)
            (when (boundp 'tab-line-mode)
              (should-not tab-line-mode)))
          (with-current-buffer buf1
            (pro-tabs-mode 0))
          (with-current-buffer buf2
            (pro-tabs-mode 0)))
      (kill-buffer buf1)
      (kill-buffer buf2))))

(ert-deftest pro-tabs-e2e-properly-inherits-faces ()
  "Test that pro-tabs properly sets up face inheritance."
  (pro-tabs-mode 1)
  (unwind-protect
      (progn
        (should (face-attribute 'tab-bar-tab :inherit nil)))
    (pro-tabs-mode 0)))

(ert-deftest pro-tabs-e2e-format-cache-works ()
  "Test that format caching works correctly."
  (let ((buf (get-buffer-create "*pro-tabs-cache-test*")))
    (unwind-protect
        (with-current-buffer buf
          (pro-tabs-mode 1)
          (let* ((result1 (pro-tabs-format-tab-line buf nil))
                 (result2 (pro-tabs-format-tab-line buf nil)))
            (should (string= result1 result2))))
      (pro-tabs-mode 0)
      (kill-buffer buf))))

(provide 'pro-tabs-e2e-test)
;;; pro-tabs-e2e-test.el ends here
