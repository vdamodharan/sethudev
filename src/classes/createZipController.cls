public with sharing class createZipController {
	
	public string behaviorName { get ; set ; }
	
	public string testClassName { get ; set ; }
	
	public string PackageXml { get ; set ; }
	
	public string TriggerMetadata { get ; set ; }
	
	public string triggerdata { get ; set ; }
	
	public string TestClassMetadata { get ; set ; }
	
	public string TestClass { get ; set ; }
	
	public createZipController(){
		behaviorName = MetadataDeployController.behaviorName;
		testClassName = MetadataDeployController.testClassName; 
		PackageXml = MetadataDeployController.getPackageXml();
		TriggerMetadata = MetadataDeployController.getTriggerMetadata();
		triggerdata = MetadataDeployController.gettrigger();
		TestClassMetadata = MetadataDeployController.getTestClassMetadata();
		TestClass = MetadataDeployController.getTestClass();
	} 
	
	
	
}