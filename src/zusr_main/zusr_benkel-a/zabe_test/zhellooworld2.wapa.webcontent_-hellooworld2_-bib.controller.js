var c = sap.ui.commons;                                                                                                                                                                                                                                        
var gv_id;                                                                                                                                                                                                                                                     
var tf1 = new sap.ui.commons.TextField({});                                                                                                                                                                                                                    
var tf2 = new sap.ui.commons.TextField({});                                                                                                                                                                                                                    
var tf3 = new sap.ui.commons.TextField({});                                                                                                                                                                                                                    
var tf4 = new sap.ui.commons.TextField({});                                                                                                                                                                                                                    
var model ;                                                                                                                                                                                                                                                    
sap.ui.controller("hellooworld2.bib", {                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                               
/**                                                                                                                                                                                                                                                            
* Called when a controller is instantiated and its View controls (if available) are already created.                                                                                                                                                           
* Can be used to modify the View before it is displayed, to bind event handlers and do other one-time initialization.                                                                                                                                          
* @memberOf hellooworld2.TEST                                                                                                                                                                                                                                  
*/                                                                                                                                                                                                                                                             
	onInit: function() {                                                                                                                                                                                                                                          
//                                                                                                                                                                                                                                                             
                                                                                                                                                                                                                                                               
	},                                                                                                                                                                                                                                                            
	createContent : function(oController) {                                                                                                                                                                                                                       
		                                                                                                                                                                                                                                                             
	},                                                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                               
	Id: function( tf_id ,tf_dok, tf_name, tf_nachname)                                                                                                                                                                                                            
	{	                                                                                                                                                                                                                                                            
		tf1 = tf_id;                                                                                                                                                                                                                                                 
		tf2 = tf_dok;                                                                                                                                                                                                                                                
		tf3 = tf_name;                                                                                                                                                                                                                                               
		tf4 = tf_nachname;                                                                                                                                                                                                                                           
		//alert("fuck");                                                                                                                                                                                                                                             
	},                                                                                                                                                                                                                                                            
/**                                                                                                                                                                                                                                                            
* Similar to onAfterRendering, but this hook is invoked before the controller's View is re-rendered                                                                                                                                                            
* (NOT before the first rendering! onInit() is used for that one!).                                                                                                                                                                                            
* @memberOf hellooworld2.TEST                                                                                                                                                                                                                                  
*/                                                                                                                                                                                                                                                             
	onBeforeRendering: function() {                                                                                                                                                                                                                               
//                                                                                                                                                                                                                                                             
		//var test = sessionStorage.getItem('myKeyString');  // Get saved string                                                                                                                                                                                     
		var id  = sessionStorage.getItem('Id');  // Get saved string                                                                                                                                                                                                 
		var dok = sessionStorage.getItem('Dokument'); //Set value                                                                                                                                                                                                    
		var name = sessionStorage.getItem('name'); //Set value                                                                                                                                                                                                       
		var nachname = sessionStorage.getItem('nachname'); //Set value                                                                                                                                                                                               
		var lv_model = sessionStorage.getItem('Model');                                                                                                                                                                                                              
		model = lv_model;                                                                                                                                                                                                                                            
		gv_id = id;                                                                                                                                                                                                                                                  
		                                                                                                                                                                                                                                                             
		tf1.setValue(id);                                                                                                                                                                                                                                            
		tf2.setValue(dok);                                                                                                                                                                                                                                           
		tf3.setValue(name);                                                                                                                                                                                                                                          
		tf4.setValue(nachname);                                                                                                                                                                                                                                      
		                                                                                                                                                                                                                                                             
		//var oRouter = sap.ui.core.UIComponent.getRouterFor(this);                                                                                                                                                                                                  
        //oRouter.getRoute("viewCarts").attachMatched(this._onRouteMatched, this);                                                                                                                                                                             
       // alert(id);                                                                                                                                                                                                                                           
	},                                                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                               
/**                                                                                                                                                                                                                                                            
* Called when the View has been rendered (so its HTML is part of the document). Post-rendering manipulations of the HTML could be done here.                                                                                                                   
* This hook is the same one that SAPUI5 controls get after being rendered.                                                                                                                                                                                     
* @memberOf hellooworld2.TEST                                                                                                                                                                                                                                  
*/                                                                                                                                                                                                                                                             
	onAfterRendering: function() {                                                                                                                                                                                                                                
		                                                                                                                                                                                                                                                             
//                                                                                                                                                                                                                                                             
		                                                                                                                                                                                                                                                             
	},                                                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                               
/**                                                                                                                                                                                                                                                            
* Called when the Controller is destroyed. Use this one to free resources and finalize activities.                                                                                                                                                             
* @memberOf hellooworld2.TEST                                                                                                                                                                                                                                  
*/                                                                                                                                                                                                                                                             
	onExit: function() {                                                                                                                                                                                                                                          
//                                                                                                                                                                                                                                                             
		alert("id");                                                                                                                                                                                                                                                 
	}                                                                                                                                                                                                                                                             
                                                                                                                                                                                                                                                               
});                                                                                                                                                                                                                                                            