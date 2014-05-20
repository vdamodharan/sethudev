global class SSOUserManager{
    // Getting calues from custom settings
    String X_API_Key = RestService.GetMapValue('X_API_Key');
    String X_Service_Id = RestService.GetMapValue('X_Service_Id');
    String AuthEndpoint = RestService.GetMapValue('AuthEndpoint');
    private void UpdateUserFeatures(Contact[] users, Boolean isTriggerUpdate){
        for(Contact user : users){
            if(user.YSI_Admin_Contact__c == true){
                getAuthToken(user, 'grant');    
            }else{
                if(isTriggerUpdate == true){
                    getAuthToken(user, 'revoke');
                }
            }
        }
    }
    private void getAuthToken(Contact user, String action){
        if(user.Email != null && !String.isEmpty(user.Email)){
            String[] headers = new List<String>();
            headers.add('X-Api-Key:'+X_API_Key);
            headers.add('X-Service-Id:'+X_Service_Id);
            headers.add('X-Original-User-Agent:mozilla');
            String method = 'GET';
            String endpoint = AuthEndpoint;
            // web service call to update the user information in yousendit Lithium community
            RestService.RESTService(endpoint, method, user.Email, headers, action);
        }
    }

    public void UpdateSSOUserFeatures(Contact[] users, Boolean isTriggerUpdate){
        UpdateUserFeatures(users, isTriggerUpdate);
    }
}