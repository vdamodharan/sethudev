@isTest(seealldata=true)
private class testSSOUsersManager{
     @isTest static void testSSOUserManagerAdmin() {              
        Contact con = new Contact(LastName='testsso',Email='test_sso.12@cloud123.com',YSI_Admin_Contact__c=true);
        test.startTest();
        insert con;
        test.stopTest();
    }
    @isTest static void testSSOUserManagerNotAdmin() {              
        Contact con = new Contact(LastName='testsso',Email='test_sso.12@cloud123.com');
        test.startTest();
        insert con;
        test.stopTest();
    }
    @isTest static void testSSOUserManagerNotUserAdmin() {              
        Contact con = new Contact(LastName='testsso12',Email='testsso12@cloud123.com',YSI_Admin_Contact__c=true);
        test.startTest();
        insert con;
        test.stopTest();
    }
    @isTest static void testSSOUserManagerNotUserAdmin1() {              
        Contact con = new Contact(LastName='testsso12',Email='testsso12_45345@cloud123.com',YSI_Admin_Contact__c=true);
        test.startTest();
        insert con;
        test.stopTest();
    }
    @isTest static void testSSOUserManagerUser1Admin() {              
        Contact con = new Contact(LastName='testsso12',Email='jasim123_test@test.com');
        test.startTest();
        insert con;
        test.stopTest();
    }
    @isTest static void testSSOUserManagerUser1NotAdmin() {              
        Contact con = new Contact(LastName='testsso12',Email='jasim123_test@test.com');
        test.startTest();
        insert con;
        test.stopTest();
    }   
}