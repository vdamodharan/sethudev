@isTest
private class HelloWorldTestClass{
    static testMethod void validateHelloWorld(){
        Book__c book = new Book__c(Name='Behind the cloud', Price__c=100);
        System.debug('Price before inserting new Book' + book.Price__c);
        insert book;
        book = [SELECT Price__c FROM Book__c WHERE Id=:book.id];
        System.debug('Price after inseting new book' + book.Price__c);
        System.assertEquals(90, book.Price__c);
    }
}