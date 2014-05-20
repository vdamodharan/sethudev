/**
 * Copyright (c) 2012, FinancialForce.com, inc
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *      this list of conditions and the following disclaimer in the documentation 
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors 
 *      may be used to endorse or promote products derived from this software without 
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

public with sharing class MetadataDeployController 
{
	public static String ZipData { get; set; }	
	
	public Static String behaviorName { get; set; }
	
	public static MetadataService.AsyncResult AsyncResult {get; private set;}
	
	public Static String objList { get; set; }
	
	public List<SelectOption> objListOptions { get; set; }
	
	public List<SelectOption> availableFields { get; set; } 
	
	public Static string activeFields { get; set; } 
	
	public Static String triggerOptionsList { get; set; }
	
	public List<SelectOption> triggerOptions { get; set;}
	
	public Static String testClassName { get ; set ; }
	
	public string callfunc { get ; set ;}
	
	public boolean deployed { get; set; } 
	
		//triggers and testclass to be deleted
  	public List<triggerClassData> triggerandTestclassData									{get;set;}
  
	
  	public class triggerClassData{
  		public string triggerName {get;set;}
  		public string triggerBody {get;set;}
  		public string testClassNam {get;set;}
  		public string testClassBody {get;set;}
  		public triggerClassData(String triggername, String triggerBody, String testClassNam, string testClassBody){
  			this.triggerName = triggerName;
  			this.triggerBody = triggerBody;
  			this.testClassNam = testClassNam;
  			this.testClassBody = testClassBody;
  		}
  	}
  	
  	public void getallData(){
  		triggerandTestclassData = new List<triggerClassData>();
  		triggerClassData tt = new triggerClassData('trignew',getTriggerBody('trignew','insert'),'trignew',getTestClassBod('trignew'));
  		triggerClassData tt2 = new triggerClassData('trigneww',getTriggerBody('trigneww','insert'),'trigneww',getTestClassBod('trigneww'));
		triggerandTestclassData.add(tt);
  		triggerandTestclassData.add(tt2);
  	}
  	//getTriggerBody -gets the trigger body
	public string  getTriggerBody(string name, string operation){
		return 'trigger ' + name + ' on contact (after ' + operation + '){}';
	}
	
	
	//getTestClassBody -gets the test class body
	public string  getTestClassBod(string name){
		return '@isTest ' + 
				'public class ' + name + 
				'{' + 
				'public static testmethod void testtrigger()' +
				'{' + 
					
				'}' +
			'}';  
	}
	
	
	public void DeployvariableSet(){
		deployed = true;
	}
	
	public static String getPackageXml()
	{
		return '<?xml version="1.0" encoding="UTF-8"?>' + 
			'<Package xmlns="http://soap.sforce.com/2006/04/metadata">' + 
    			'<types>' + 
        			'<members>trignew</members>' +
        			'<name>ApexTrigger</name>' +
        		'</types>' + 
        		'<types>' + 
        			'<members>trigneww</members>' +
        			'<name>ApexTrigger</name>' +
        		'</types>' + 
        		'<types>' + 
       			'<members>trignew</members> ' +
        		'<name>ApexClass</name>' + 
    			'</types> ' + 
    			'<types>' + 
       			'<members>trigneww</members> ' +
        		'<name>ApexClass</name>' + 
    			'</types> ' + 
    			'<version>26.0</version>' +
    		'</Package>';
    		
  }
  
  
static	{
  	setBehaviornames(); 
  }
  
	public void objFieldOptions(){
		availableFields = new List<SelectOption>();
	 	//get all available fields on the object selected - should we remove our managed objects? 
	 	SObjectType objectType = Schema.getGlobalDescribe().get(objList);
	 	if(objectType != null){
	 		activeFields = '';
	 		Schema.DescribeSObjectResult objResult = objectType.getDescribe();
			Map<String, Schema.SObjectField> MapOfObjectfields = objResult.fields.getMap();
	        for(string fieldname : MapOfObjectfields.KeySet()){
	            Schema.DescribeFieldResult objFieldResult = MapOfObjectfields.get(fieldname).getDescribe();
	            availableFields.add(new SelectOption(objFieldResult.getName(),objFieldResult.getLabel()));
	 		}
	 	}
	 	else{
	 		availableFields.clear();
	 		activeFields = '';
	 	}
	}
	

	
	public 	MetadataDeployController(){
		try{
			setBehaviornames();
			//get the list of objects available, fields and the trigger options
			fetchObjectList();
			objFieldOptions();
			fetchTriggerOptions();
			getallData();
		}
		catch(Exception ex){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
		}
	}
	
	public static void setBehaviornames(){
		if(ApexPages.currentPage().getParameters().get('name_of_behavior') != null){
			behaviorName = ApexPages.currentPage().getParameters().get('name_of_behavior'); 
			if(behaviorName.length() > 30){
				testClassName = 'Test_B_' + behaviorName.substring(0,30);
			}
			else
				testClassName = 'Test_B_'  + behaviorName;
		}
	}
	
	
	public void fetchTriggerOptions(){
		triggerOptions = new List<SelectOption>();
		triggerOptions.add(new SelectOption('insert','After the object selected above is created'));
		triggeroptionsList = 'insert';
		triggerOptions.add(new SelectOption('update','After the object selected above is updated'));
	}
	
	public void fetchObjectList(){
		if(objList == null){
		 	objList = 'Lead';
		}
		objListOptions = new List<SelectOption>();
		Map<String, Schema.SObjectType> mapofObjects = Schema.getGlobalDescribe();
		for( string objname : mapofObjects.keyset()){
			Schema.DescribeSObjectResult objResult = mapofObjects.get(objname).getDescribe();
			if(objResult.iscustom() && !objResult.isCustomSetting() /*&& objResult.getName() == objResult.getlocalname()*/){
				objListOptions.add(new SelectOption(objResult.getName(),objResult.getLabel()));
			}
			if(!objResult.iscustom() && !objResult.isCustomSetting() && objResult.getName().equalsIgnoreCase('lead') || objResult.getName().equalsIgnoreCase('account') || objResult.getName().equalsIgnoreCase('user') || objResult.getName().equalsIgnoreCase('contact') || objResult.getName().equalsIgnoreCase('opportunity')){
				objListOptions.add(new SelectOption(objResult.getName(),objResult.getLabel()));
			}
		}
	}
	
	public static String getTriggerMetadata()
	{
		
		return '<?xml version="1.0" encoding="UTF-8"?>'+
				'<ApexTrigger xmlns="http://soap.sforce.com/2006/04/metadata">'+
    				'<apiVersion>26.0</apiVersion>'+
    				'<status>deleted</status>' +
				'</ApexTrigger>';
	}
	
	public static String getTrigger()	
	{
		List<String> fieldList = ActiveFieldsList();
		String temp = '';
		for(integer i=0; i< fieldList.size(); i++){
			if(temp == '')
				temp = 'if( ' + objList + 'record.' + fieldList.get(i) + '!=null';
			else
				temp += ' && ' + objList + 'record.' + fieldList.get(i) + '!=null';  
			
		}	
		if(temp != '')
			temp += ' ) {system.debug(\'test\');}';
		string test = 'trigger ' + behaviorName + ' on ' + objList + ' (after ' + triggeroptionsList + '){ '+
 				objList + ' ' + objList + 'record = Trigger.new[0];' +
 				temp + 
 				' }';
 		system.debug('>>>test' + test);
 		system.debug('>>>temp' + temp);
 		return test;
	}
  	 

  	public static List<string> ActiveFieldsList(){
  		 List<string> activeFieldsList = new List<string>();
  		 if(activefields != null && activefields != '[]' && activefields != ''){
            String fieldslist = activefields.substring(1,activefields.length() - 1);
            for(String field : fieldslist.split(',')){
            	field = field.trim();	
            	activeFieldsList.add(field);
            }
            system.debug('>>activeFieldsList' + activeFieldsList);
  		 }
  		 return activeFieldsList;
  	}
	
	public static String getTestClassMetadata()
	{
		return '<?xml version="1.0" encoding="UTF-8"?>' +
				'<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">' +
			   		 '<apiVersion>26.0</apiVersion>' +
			    	  '<status>deleted</status>' +
				'</ApexClass>';
	}
	
	public static String getTestClass()	
	{
		/*string test = '@isTest  private class ' + testClassName + ' { ' + 
				'static testMethod void testAutoGeneratedTrigger() {  ' + getTestClassBody() + ' }  }';	
		system.debug('>>>>>claa' + test);
		return '@isTest  private class ' + testClassName + '{  ' + 
				'static testMethod void testAutoGeneratedTrigger() {  ' + getTestClassBody() + ' }  }'; */
				
		return '@isTest ' + 
				'public class ' + testClassName + 
				'{' + 
				'public static testmethod void testtrigger()' +
				'{' + 
					getTestClassBody() +
				'}' +
			'}';  
 	}
		
	
	
	public static String getTestClassBody(){
		return ' try { ' + objList + ' testObject = new ' + objList + '(' + getMandatoryFieldValues() + '); insert testObject; ' +
			     objList + ' updatedObject = [SELECT Id FROM ' + objList + ' WHERE Id = : testObject.Id]; ' +  
			   ' upsert updatedObject; }' +
			   ' catch(Exception ex){ System.debug(ex.getMessage()); }' ;
	}
	
	public static void getMandatoryFields(Map<string,string> mapofMandatoryFields){
		Schema.SobjectType objResult = Schema.getGlobalDescribe().get(objList);
		Map<String, Schema.SObjectField> MapOfObjectfields = objResult.getDescribe().fields.getMap();
        for(string fieldname : MapOfObjectfields.KeySet()){
            Schema.DescribeFieldResult objFieldResult = MapOfObjectfields.get(fieldname).getDescribe();
            if(!objFieldResult.isNillable() && objFieldResult.isUpdateable()){
            	mapofMandatoryFields.put(objFieldResult.getName(),'' + objFieldResult.getType());
            }
       }
       for(string selectedfieldname : ActiveFieldsList()){
       		Schema.DescribeFieldResult objFieldResult = MapOfObjectfields.get(selectedfieldname).getDescribe();
            if(objFieldResult.isUpdateable()){
            	mapofMandatoryFields.put(objFieldResult.getName(),'' + objFieldResult.getType());
            }
       }
	}
	
	public static string getMandatoryFieldValues(){
		Map<string,string> mapofMandatoryFields = new Map<string,string>();
		getMandatoryFields(mapofMandatoryFields);
		String testClassBody = '';
		for(String field : mapofMandatoryFields.keyset()){
			if(mapofMandatoryFields.get(field).containsIgnoreCase('Boolean')){
				if(testClassBody != null && testClassBody != '')				
            		testClassBody += ', ' + field + ' = true';
            	else
            		testClassBody += field +' = true';
            }
        	else if(mapofMandatoryFields.get(field).containsIgnoreCase('String') || mapofMandatoryFields.get(field).containsIgnoreCase('Picklist') || mapofMandatoryFields.get(field).containsIgnoreCase('TextArea')){
        		if(testClassBody != null && testClassBody != '')				
            		testClassBody += ', ' +  field + ' = \'abcde\'';
            	else
            		testClassBody += field +' = \'abcde\'';
        	}
        	else if(mapofMandatoryFields.get(field).containsIgnoreCase('Phone')){
        		if(testClassBody != null && testClassBody != '')				
            		testClassBody += ', ' +  field + ' = \'121212\'';
            	else
            		testClassBody += field +' = \'121212\'';
        	}
        	else if(mapofMandatoryFields.get(field).containsIgnoreCase('Double')){
        		if(testClassBody != null && testClassBody != '')				
            		testClassBody += ', ' +  field + ' = 33.5';
            	else
            		testClassBody += field +' = 33.5';
        	}
        	else if(mapofMandatoryFields.get(field).containsIgnoreCase('email')){
        		if(testClassBody != null && testClassBody != '')				
            		testClassBody += ', ' +  field + ' = \'test@test.com\'';
            	else
            		testClassBody += field +' = \'test@test.com\'';
        	}
        	else if(mapofMandatoryFields.get(field).containsIgnoreCase('Integer')){
        		if(testClassBody != null && testClassBody != '')				
            		testClassBody += ', ' +  field + ' = 12';
            	else
            		testClassBody += field +' = 12';
        	}
        	else if(mapofMandatoryFields.get(field).containsIgnoreCase('Date')){
                if(testClassBody != null && testClassBody != '')				
        			testClassBody += ', ' +  field + ' = ' + System.today();
        		else
        			testClassBody += field +' = ' + System.today();
            }
            else if(mapofMandatoryFields.get(field).containsIgnoreCase('DateTime')){
                if(testClassBody != null && testClassBody != '')				
        			testClassBody += ', ' +  field + ' = ' + DateTime.now();
        		else
        			testClassBody += field +' = ' + DateTime.now();
            }
            else if(mapofMandatoryFields.get(field).containsIgnoreCase('URL')){
                if(testClassBody != null && testClassBody != '')				
        			testClassBody += ', ' +  field + ' = \'www.google.com\'' ;
        		else
        			testClassBody += field +' = \'www.google.com\'';
            }
            else if(mapofMandatoryFields.get(field).containsIgnoreCase('Time')){
                if(testClassBody != null && testClassBody != '')				
        			testClassBody += ', ' +  field + ' = Time.newInstance(18, 30, 2, 20);' ;
        		else
        			testClassBody += field +' = Time.newInstance(18, 30, 2, 20);';
            }
            else if(mapofMandatoryFields.get(field).containsIgnoreCase('currency')){
                if(testClassBody != null && testClassBody != '')				
        			testClassBody += ', ' +  field + ' = 12.32;' ;
        		else
        			testClassBody += field +' = 12.32;';
            }
             else if(mapofMandatoryFields.get(field).containsIgnoreCase('percent')){
                if(testClassBody != null && testClassBody != '')				
        			testClassBody += ', ' +  field + ' = 12' ;
        		else
        			testClassBody += field +' = 12';
            }
            
		}
		 return testClassBody;
    }
	
	
	public static PageReference deployZip()
	{
		system.debug('inside zip');
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Deploying...'));

		// Deploy zip file posted back from the page action function				
		MetadataService.MetadataPort service = createService();
		MetadataService.DeployOptions deployOptions = new MetadataService.DeployOptions();
        deployOptions.allowMissingFiles = false;
        deployOptions.autoUpdatePackage = false;
        deployOptions.checkOnly = false;
        deployOptions.ignoreWarnings = false;
        deployOptions.performRetrieve = false;
        deployOptions.purgeOnDelete = false;
        deployOptions.rollbackOnError = true;
        deployOptions.runAllTests = false;
        deployOptions.runTests = null;
        deployOptions.singlePackage = true;		
        system.debug('ZipData -' + ZipData);			
		AsyncResult = service.deploy(ZipData, DeployOptions);	
		return null;
	}	
	
	public static PageReference checkAsyncRequest()
	{	
		// Check the status of the retrieve request
		MetadataService.MetadataPort service = createService();
		MetadataService.AsyncResult[] aysncResults = service.checkStatus(new String[] { AsyncResult.Id });
		if(aysncResults[0].done)
		{
			// Errors?
			if(aysncResults[0].state == 'Error')
			{
			 	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, aysncResults[0].message));
				AsyncResult = null;				
			}
			else
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Deployment complete'));

				// Deployment errors?
				MetadataService.DeployResult deployResult = service.checkDeployStatus(AsyncResult.Id);
				for(MetadataService.DeployMessage deployMessage : deployResult.messages)
					if(deployMessage.problem!=null)
						ApexPages.addMessage(
							new ApexPages.Message(ApexPages.Severity.Error, 
								deployMessage.fileName + 
									' (Line: ' + deployMessage.lineNumber + ': Column:' + deployMessage.columnNumber + ') : ' + 
										deployMessage.problem));
				AsyncResult = null;
			}
		}
		else
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Deploying...'));
		}	
		return null;
	}
	
	private static MetadataService.MetadataPort createService()
	{ 
		MetadataService.MetadataPort service = new MetadataService.MetadataPort();
		service.SessionHeader = new MetadataService.SessionHeader_element();
		service.SessionHeader.sessionId = UserInfo.getSessionId();
		return service;		
	}
	
	public pagereference addTrigger(){
		pagereference pg = new pagereference('/apex/metadatadeploy?name_of_behavior=' + behaviorName);
		pg.setredirect(true);
		return pg;
	}		
}