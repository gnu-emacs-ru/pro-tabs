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

;; Можно добавить другие тесты следующим образом:
;; (ert-deftest pro-tabs-format-tab-bar-basic () ...)

(provide 'pro-tabs-test)
;;; pro-tabs-test.el ends here
