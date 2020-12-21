/* global QUnit */

QUnit.config.autostart = false;

sap.ui.getCore().attachInit(function() {
  "use strict";

  sap.ui.require([
    "com/pai/ocn/stager/test/integration/AllJourneys"
  ], function() {
    QUnit.start();
  });
});
