;;; pro-tabs-e2e-test.el --- E2E tests for pro-tabs

(require 'ert)
(require 'pro-tabs)

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

(provide 'pro-tabs-e2e-test)
;;; pro-tabs-e2e-test.el ends here
