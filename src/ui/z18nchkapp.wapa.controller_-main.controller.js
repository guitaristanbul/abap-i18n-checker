"use strict";sap.ui.define(["./BaseController","devepos/i18ncheck/model/models","devepos/i18ncheck/model/dataAccess/rest/CheckI18nService","devepos/i18ncheck/model/formatter","sap/m/Token","sap/ui/core/ValueState","sap/base/Log","sap/ui/model/Filter","sa+
p/m/MessageToast"],function(e,t,o,s,n,i,r,a,l){function u(e){return e&&e.__esModule&&typeof e.default!=="undefined"?e.default:e}const d=u(e);const c=u(t);const h=u(o);const g=u(s);const p=d.extend("devepos.i18ncheck.controller.Main",{constructor:function+
 e(){d.prototype.constructor.apply(this,arguments);this.formatter=g},onInit:function e(){d.prototype.onInit.call(this);this._oPage=this.byId("page");this._oBundle=this.getOwnerComponent().getResourceBundle();this._oModel=this.getOwnerComponent().getModel+
();this._oViewModel=c.createViewModel({compareAgainstDefault:true,showExcludedEntries:false,defaultLanguage:"en",selectedFilter:"Error",resultsTableTitle:this._oBundle.getText("resultsTableTitle",[0])});this.getView().setModel(this._oViewModel,"viewModel+
");this._oModel.setData({count:0,withoutErrorsCount:0,withErrorsCount:0});this._oTargetLanguagesInput=this.getView().byId("trgtLanguagesInput");this._oBspNameFilterInput=this.getView().byId("bspNameFilter")},onUpdateFinished:function e(){let t=0;switch(t+
his._oViewModel.getProperty("/selectedFilter")){case"Error":t=this._oModel.getProperty("/withErrorsCount");break;case"Ok":t=this._oModel.getProperty("/withoutErrorsCount");break;case"All":t=this._oModel.getProperty("/count");break;default:break}this._oVi+
ewModel.setProperty("/resultsTableTitle",this._oBundle.getText("resultsTableTitle",[t]))},onResultsPress:function e(t){const o=this.getFlexColHelper().getNextUIState(1);this.getRouter().navTo("detail",{layout:o.layout,resultPath:encodeURIComponent(t.getS+
ource().getBindingContextPath())})},onChange:function e(t){const o=t.getSource();o.data("__changing",true);if(o.isA("sap.m.MultiInput")){this._addTokensToMultiInput(o,t===null||t===void 0?void 0:t.getParameter("value"))}if(o!==null&&o!==void 0&&o.getRequ+
ired()){this._checkRequired(o)}},onSubmit:function e(t){const o=t.getSource();if(o.isA("sap.m.MultiInput")){this._addTokensToMultiInput(o,t.getParameter("value"));if(o.data("__changing")){o.data("__changing",false);return}}this.onSearch()},onSearch:async+
 function e(){if(!this._validateFields()){return}this._oViewModel.setProperty("/busy",true);const t=this._oViewModel.getData();const o={defaultLanguage:t.defaultLanguage,compareAgainstDefaultFile:t.compareAgainstDefault,targetLanguages:this._oTargetLangu+
agesInput.getTokens().map(e=>e.getKey()).join(","),bspNames:this._oBspNameFilterInput.getTokens().map(e=>encodeURIComponent(e.getKey())).join(","),showExcludedEntries:t.showExcludedEntries};let s=[];let n=0;let i=0;try{const e=new h;const t=await e.check+
Translations(o);s=t.data;for(const e of s){switch(e.status){case"S":case"W":i++;break;case"E":n++;break;default:break}}if(!s||s.length===0){l.show(this._oBundle.getText("noDataFoundMessage"))}}catch(e){const t=e.statusText?e.statusText:"Error during call+
ing the 'check i18n translations' service";r.error(t);l.show(t)}this._oModel.setData({results:s,count:s.length,withoutErrorsCount:i,withErrorsCount:n});this._oViewModel.setProperty("/busy",false);this.onFilterChange()},onFilterChange:function e(t){const +
o=this.byId("checkResults").getBinding("items");const s=this._oViewModel.getProperty("/selectedFilter");const n=[];let i;if(s==="Ok"){i=new a("status","NE","E")}else if(s==="Error"){i=new a("status","EQ","E")}if(i){n.push(i)}o.filter(n)},_addTokensToMult+
iInput:function e(t,o){var s;if(!t||!(t!==null&&t!==void 0&&t.isA("sap.m.MultiInput"))||!o){return}if((s=t.data())!==null&&s!==void 0&&s.hasOwnProperty("upperCase")){var i;if(t.data().upperCase&&(i=o)!==null&&i!==void 0&&i.toUpperCase){o=o.toUpperCase()}+
}const r=t.getTokens();if(r.filter(e=>e.getKey()===o).length<=0){t.addToken(new n({key:o,text:o}));t.setValue("")}},_checkRequired:function e(t){let o=false;let s="";if(t.isA("sap.m.MultiInput")){const e=t.getTokens();o=true;s=!e||e.length<=0?i.Error:i.N+
one;t.setValueState()}else if(t.isA("sap.m.Input")){o=true;s=!t.getValue()?i.Error:i.None}if(o){t.setValueState(s);if(s===i.Error){t.setValueStateText(this.getOwnerComponent().getResourceBundle().getText("mandatoryFieldNotFilled"))}else{t.setValueStateTe+
xt("")}}},_validateFields:function e(){const t=this.getView().getControlsByFieldGroupId("requiredParam");for(const e of t){if(!e.getRequired){continue}this._checkRequired(e);if(e!==null&&e!==void 0&&e.getRequired()&&(e===null||e===void 0?void 0:e.getValu+
eState())===i.Error){setTimeout(()=>{e.focus()},100);return false}}return true}});return p});                                                                                                                                                                  