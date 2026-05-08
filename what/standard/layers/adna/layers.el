;;; layers.el --- adna layer dependencies  -*- lexical-binding: t -*-
;;
;; Author:  Spacemacs.aDNA / Daedalus
;; License: GPL-3.0
;;
;; Loaded first by Spacemacs; declares load-order dependency on spacemacs-bootstrap
;; so transient (used in keybindings.el) is guaranteed available before adna loads.

(configuration-layer/declare-layer-dependencies '(spacemacs-bootstrap))

;;; layers.el ends here
