sap.ui.define(
  [
    "com/pai/ocn/stager/controller/BaseController",
    "../model/models",
    "sap/ui/model/json/JSONModel",
    "../libs/socket",
    "sap/m/Dialog",
    "sap/m/DialogType",
    "sap/m/Button",
    "sap/m/ButtonType",
    "sap/m/List",
    "sap/m/StandardListItem",
    "sap/m/Text",
    "sap/ui/core/Fragment",
  ],
  function (
    Controller,
    models,
    JSONModel,
    socket,
    Dialog,
    DialogType,
    Button,
    ButtonType,
    List,
    StandardListItem,
    Text,
    Fragment
  ) {
    "use strict";
    var audio;
    var interval;
    return Controller.extend("com.pai.ocn.stager.controller.stagerView", {
      onInit: function () {
        this.setModel(models.createMainModel());
      },

      onAfterRendering: function () {
      
      },
      onNewStage: function () {
       document.getElementById("fireworks").hidden = false;
        let that = this;
        let random = Math.floor(Math.random() * 3);

        const oBundle = this.getView().getModel("i18n").getResourceBundle();
 
        $.get(
          "/catalog/Employees?$filter=Selected eq false&$count=true"//&$skip=" + random
        ).done(
            function (oResult) {
              var number = oResult['@odata.count'];
              let random = Math.floor(Math.random() * number);
             


              if(oResult.value.length == 0) {

                return sap.m.MessageToast.show('Hata: Kullanıcı Bulunamadı', {
                  duration: 10000, 
                  width: "15rem", // default max width supported 
                });
 
              }

              setTimeout(() => {
                document.getElementById("fireworks").hidden = true;
              }, 10000);

              that.getView().getModel("main").setData(oResult.value[random]);

              var oEntry = {
                Name: oResult.value[random].Name,
                Gender: oResult.value[random].Gender,
                Selected: true

              };
 
 

              $.ajax("/catalog/Employees("+oResult.value[random].Catid+")", {
                method: "PUT",
                contentType: "application/json",
            
                data: JSON.stringify(oEntry),
                success: function (data) {
                  
                  sap.m.MessageToast.show(oResult.value[random].Name, {
                    duration: 10000, 
                    width: "45rem", // default max width supported 
                  });


                }.bind(this),
                error: function (xhr, errorText, error) {
            
                   
                }.bind(this)
              });

             
          
            }.bind(this)
         ).fail(function () {});
      },

      generateRandom: function makeid(length) {
        var result = "";
        var characters =
          "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        var charactersLength = characters.length;
        for (var i = 0; i < length; i++) {
          result += characters.charAt(
            Math.floor(Math.random() * charactersLength)
          );
        }
        return result;
      }
    });
  }
);
