"use strict";sap.ui.define(["devepos/i18ncheck/controller/BaseController"],function(t){function e(t){return t&&t.__esModule&&typeof t.default!=="undefined"?t.default:t}const o=e(t);const n=o.extend("devepos.i18ncheck.controller.App",{onInit:function t(){+
o.prototype.onInit.call(this);this.oRouter.attachRouteMatched(this.onRouteMatched,this);this.oRouter.attachBeforeRouteMatched(this.onBeforeRouteMatched,this)},onBeforeRouteMatched:function t(e){let o=e.getParameters().arguments.layout;if(!o){const t=this+
.getOwnerComponent().getHelper().getNextUIState(0);o=t.layout}if(o){this.oLayoutModel.setProperty("/layout",o)}},onRouteMatched:function t(e){const o=e.getParameter("name");const n=e.getParameter("arguments");this._updateUIElements();this._sCurrentRouteN+
ame=o;this._sCurrentPath=n.resultPath;this._sCurrentDetailEntryPath=n.detailPath},onStateChanged:function t(e){const o=e.getParameter("isNavigationArrow");const n=e.getParameter("layout");this._updateUIElements();if(o){this.oRouter.navTo(this._sCurrentRo+
uteName,{layout:n,resultPath:this._sCurrentPath,detailPath:this._sCurrentDetailEntryPath},true)}},_updateUIElements:function t(){const e=this.getOwnerComponent().getHelper().getCurrentUIState();this.oLayoutModel.setData(e)},onExit:function t(){this.oRout+
er.detachRouteMatched(this.onRouteMatched,this);this.oRouter.detachBeforeRouteMatched(this.onBeforeRouteMatched,this)}});return n});                                                                                                                           