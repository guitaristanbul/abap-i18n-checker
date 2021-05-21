"use strict";sap.ui.define(["./BaseController","../model/formatter","../model/models","../model/dataAccess/rest/RepositoryInfoService","../model/dataAccess/rest/CheckI18nService","../model/util/AsyncDialog","sap/base/Log","sap/base/strings/formatMessage"+
,"sap/m/MessageToast","sap/ui/core/Fragment"],function(e,t,o,n,s,i,a,l,r,c){function d(e){return e&&e.__esModule&&typeof e.default!=="undefined"?e.default:e}const u=d(e);const g=d(t);const h=d(o);const f=d(n);const m=d(s);const p=d(i);const y=u.extend("d+
evepos.i18ncheck.controller.Detail",{constructor:function e(){u.prototype.constructor.apply(this,arguments);this.formatter=g;this.formatMessage=l},onInit:function e(){this._oLayoutModel=this.getOwnerComponent().getLayoutModel();this._oBundle=this.getOwne+
rComponent().getResourceBundle();this._oViewModel=h.createViewModel({excludeActionEnabled:false,includeActionEnabled:false,busy:false});this._oTable=this.byId("i18nMessages");this.getView().setModel(this._oViewModel,"viewModel");const t=this.getRouter();+
t.getRoute("main").attachPatternMatched(this._onRouteMatched,this);t.getRoute("detail").attachPatternMatched(this._onRouteMatched,this)},onMessageTableSelectionChange:function e(){let t=false;let o=false;for(const e of this._oTable.getSelectedContexts())+
{if(e.getProperty("ignEntryUuid")){o=true}else{t=true}}this._oViewModel.setProperty("/excludeActionEnabled",t);this._oViewModel.setProperty("/includeActionEnabled",o)},onAssignGitRepo:async function e(t){const o=this.getView().getBindingContext();const n+
=o===null||o===void 0?void 0:o.getObject();if(!n){return}const s=h.createViewModel({url:n.gitUrl});const i=new p({title:this._oBundle.getText("gitRepositoryAssignDialogTitle"),width:"45em",height:"8em",content:await c.load({type:"XML",name:"devepos.i18nc+
heck.fragment.ChangeGitRepo"}),model:s});const l=await i.showDialog(this.getView());if(l!==p.OK_BUTTON){return}const d=s.getProperty("/url");if(d===n.gitUrl){return}try{const e=new f;await e.updateRepoInfo({bspName:n.bspName,gitUrl:d});o.getModel().setPr+
operty(`${o.sPath}/gitUrl`,d);r.show(this._oBundle.getText("gitRepoUrlUpdated",n.bspName))}catch(e){a.error(e)}},onExcludeMessages:async function e(){this._createIgnoreMessageEntries(e=>!e.ignEntryUuid,e=>({messageType:e.messageType,filePath:e.file.path,+
fileName:e.file.name,i18nKey:e.key}),this._updateIgnoreEntries.bind(this))},onIncludeMessages:async function e(){this._createIgnoreMessageEntries(e=>!!e.ignEntryUuid,e=>({ignEntryUuid:e.ignEntryUuid}),this._clearIgnoredKeyFromEntries.bind(this),true)},ha+
ndleItemPress:function e(t){},handleFullScreen:function e(){const t=this._oLayoutModel.getProperty("/actionButtonsInfo/midColumn/fullScreen");this.getRouter().navTo("detail",{layout:t,resultPath:encodeURIComponent(this._sResultPath)})},handleExitFullScre+
en:function e(){const t=this._oLayoutModel.getProperty("/actionButtonsInfo/midColumn/exitFullScreen");this.getRouter().navTo("detail",{layout:t,resultPath:encodeURIComponent(this._sResultPath)})},handleClose:function e(){var t=this._oLayoutModel.getPrope+
rty("/actionButtonsInfo/midColumn/closeColumn");this.getRouter().navTo("main",{layout:t})},_onRouteMatched:function e(t){const o=decodeURIComponent(t.getParameter("arguments").resultPath)||this._sResultPath||"";if(o){this._sResultPath=o}this.getView().bi+
ndElement({path:o})},_createIgnoreMessageEntries:async function e(t,o,n,s){var i;const l=this._oTable.getSelectedContexts();if((l===null||l===void 0?void 0:l.length)<=0){return}const c=(i=this.getView().getBindingContext())===null||i===void 0?void 0:i.ge+
tObject();if(!c){return}this._oViewModel.setProperty("/busy",true);const d=[];const u=[];for(const e of l){const n=e.getObject();if(!t(n)){continue}u.push(e);d.push(Object.assign({bspName:c.bspName},o(n)))}if(d.length>0){try{var g;const e=new m;const t=s+
?await e.deleteIgnoredMessages(d):await e.ignoreMessages(d);if((t===null||t===void 0?void 0:(g=t.data)===null||g===void 0?void 0:g.length)>0){var h;n(t.data,u);this.getOwnerComponent().getModel().updateBindings();this._oTable.removeSelections();const e=s+
?"messagesIncludedSuccess":"messagesExcludedSuccess";r.show(this._oBundle.getText(e,t===null||t===void 0?void 0:(h=t.data)===null||h===void 0?void 0:h.length))}}catch(e){if(e!==null&&e!==void 0&&e.statusText){a.error(e.statusText)}else{a.error(e)}}}this.+
_oViewModel.setProperty("/busy",false)},_clearIgnoredKeyFromEntries:function e(t,o){if((t===null||t===void 0?void 0:t.length)!==(o===null||o===void 0?void 0:o.length)){return}for(const e of o){const t=e.getObject();t.ignEntryUuid=""}},_updateIgnoreEntrie+
s:function e(t,o){if((t===null||t===void 0?void 0:t.length)!==(o===null||o===void 0?void 0:o.length)){return}for(const e of o){const o=e.getObject();const n=t.find(e=>e.fileName===o.file.name&&e.filePath===o.file.path&&e.messageType===o.messageType&&e.i1+
8nKey===o.key);if(n){o.ignEntryUuid=n.ignEntryUuid}}}});return y});                                                                                                                                                                                            