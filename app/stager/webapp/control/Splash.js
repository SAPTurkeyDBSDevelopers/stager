sap.ui.define(
  ["sap/ui/core/Control","sap/ui/core/Icon","sap/m/Button"],
  function (Control,Icon,Button) {
    return Control.extend("com.pai.ocn.stager.control.Splash", {
      metadata: {
        properties: {
          type: { type: "string" }
        },
        aggregations: {
          _playgame: { type: "sap.m.Button", multiple: false }

        },
        events: {
          hideSplash: {}
        }
      },
      init: function () {

  

        this.setAggregation("_playgame", new Button({
          text: "{i18n>playGame}",
          press: function () {
            this.fireHideSplash();
          }.bind(this)
        }).addStyleClass("mystartbutton"));


      },
      renderer: {
        apiVersion: 2,
        render: function (oRm, oControl) {



          oRm.openStart("div");
          oRm.attr("id", "splashScreen");
          oRm.class("splash");
          oRm.openEnd();
          


          //add another div for image
          oRm.openStart("div");
          oRm.class("splashview-hero");
          oRm.openEnd();
 
          oRm.close("div");

          //close another div for image
     
          oRm.close("div");
 
        }
      }
    });
  }
);
