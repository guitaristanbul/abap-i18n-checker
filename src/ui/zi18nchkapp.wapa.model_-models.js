"use strict";sap.ui.define(["sap/ui/model/json/JSONModel","sap/ui/Device"],function(e,n){var i={createDeviceModel(){const i=new e(n);i.setDefaultBindingMode("OneWay");return i},createViewModel(n){return new e(n)}};return i});                              