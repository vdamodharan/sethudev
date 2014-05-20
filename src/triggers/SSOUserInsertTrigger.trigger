trigger SSOUserInsertTrigger on Contact (after insert, after update) {
    // Trigger to update the contact in yousendit Lithium community
    Contact[] contacts = trigger.new;
    SSOUserManager SSOMgr = new SSOUserManager();
    Boolean isTriggerUpdate = trigger.isUpdate;
    SSOMgr.UpdateSSOUserFeatures(contacts, isTriggerUpdate);
    SSOMgr = null;
}