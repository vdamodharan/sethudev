global class RestService{
    // yousendit auth API response skeleton
    class SSoAuthResponse{
        String lithiumAuthToken;
        SSOErrorStatus errorStatus;
    }
    class SSOErrorStatus{
        String code;
        String message;
    }

    // Lithium auth API response skeleton
    class LithiumAuthResponse{
        LithiumResponse response;
    }
    class LithiumResponse{
        LithiumToken value;
        LithiumError error;
        String status;
    }
    class LithiumToken{
        String dollar;
    }
    class LithiumError{
        String code;
        String message;
    }

    // Lithium user info API response skeleton
    class LithiumUserInfoResponse{
        LithiumUserResponse response;
    }
    class LithiumUserResponse{
        LithiumUser user;
    }
    class LithiumUser{
        LithiumUserId id;
        LithiumUserLogin login;
    }
    class LithiumUserId{
        integer dollar;
    }
    class LithiumUserLogin{
        String dollar;
    }

    // Object to cache Lithium user info
    class SessionUserInfo{
        String login;
        String id;
    }

    private static SessionUserInfo SessionUser_Info = null;

    // Getting custom settings value to hash map
    public static Map<string,YSISSOConfig__c> SettingsMap = YSISSOConfig__c.getAll();
    static String user_email = '';
    static String display_name = '';
    static String admin_session_key = '';
    static String user_session_key = '';

    // Retrieve custom settings value coresponding to given key
    public static String GetMapValue(String key){
        if(SettingsMap.containsKey(key) && !String.isEmpty(SettingsMap.get(key).value__c)){
            return SettingsMap.get(key).value__c;    
        }
        return '';
    }

    static String baseUrl = GetMapValue('CommunityBaseUrl');

    static Map<String,String> ResponseMap;


    // fake web service response for test class
    private static void BuildFakeResponseMap(){
        ResponseMap = new Map<String,String>();
        ResponseMap.put(baseUrl+'/authentication/sessions/login','{"response":{"status":"success","value":{"type":"string","$":"MoIItdMcyvct5-q5W_lMDPKgy3C8GDdINRJmw8vQeag."}}}');
        ResponseMap.put(baseUrl+'/authentication/sessions/current/user','{"response":{"status":"success","user":{"id":{"type":"int","$":177},"login":{"type":"string","$":"swarna0710"}}}}');
        ResponseMap.put(baseUrl+'/roles/name/ADM/users/add','{"response":{"status":"success"}}');
        ResponseMap.put(baseUrl+'/roles/name/ADM/users/remove','{"response":{"status":"success"}}');
        ResponseMap.put(baseUrl+'/boards/id/SiteStatus/subscriptions/users/self/add','{"response":{"status":"success"}}');
        ResponseMap.put(baseUrl+'/boards/id/SiteStatus/subscriptions/users/self/type/email/remove','{"response":{"status":"success"}}');
        ResponseMap.put(baseUrl+'/boards/id/EnterpriseBulletin/subscriptions/users/self/add','{"response":{"status":"success"}}');
        ResponseMap.put(baseUrl+'/boards/id/EnterpriseBulletin/subscriptions/users/self/type/email/remove','{"response":{"status":"success"}}');
        ResponseMap.put('oauthsuccess','{"lithiumAuthToken":"~2pF5LxlICuFlVDtFY~5G6w"}');
        ResponseMap.put('useremailinfo','{"response":{"status":"success","user":{"id":{"type":"int","$":177},"login":{"type":"string","$":"swarna0710"}}}}');
        ResponseMap.put('setuserlogin','{"response":{"status":"success"}}');
    }

    private static String GetFakeResponse(String url){
        if(ResponseMap == null){
            BuildFakeResponseMap();
        }
        String response = '';
        if(ResponseMap.containsKey(url)){
            response = ResponseMap.get(url);
        }
        return response;
    }

    // common method to make REST API calls
    private static HttpResponse CallRestService(String url, String method, String[] params, String[] headers){
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        Http http = new Http();

        request.setMethod(method);

        // adding Lithium htaccess values to header
        if(!String.isEmpty(GetMapValue('CommunityHTaccess'))){
            Blob headerValue = Blob.valueOf(GetMapValue('CommunityHTaccess'));
            String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
            request.setHeader('Authorization', authorizationHeader);
        }
        
        request.setHeader('Accept', 'application/json');
        String BodyParams = '';
        if(params.size() > 0){
            for(String key : params){
                if(String.isEmpty(user_email) && key.split(':')[0] == 'email'){
                    user_email = key.split(':')[1]; 
                }
                if(String.isEmpty(display_name) && key.split(':')[0] == 'login'){
                    display_name = key.split(':')[1]; 
                }
                if(BodyParams != ''){
                    BodyParams += '&';  
                }
                if(key.split(':').size() > 1){
                    BodyParams += key.split(':')[0] + '=' + key.split(':')[1];    
                }
            }
        }
        if(method.equals('GET')){
            url = url + '?' + BodyParams;
        }
        if(method.equals('POST')){
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.setBody(BodyParams);
        }
        request.setEndpoint(url);
        if(headers.size() > 0){
            for(String key : headers){
                request.setHeader(key.split(':')[0], key.split(':')[1]);
            }
        }
        try{
            // for test class
            if (Test.isRunningTest()) {
                String fakeBody = GetFakeResponse(url);
                Pattern url_match = Pattern.compile(GetMapValue('AuthEndpoint') + '.*');
                Matcher url_matcher = url_match.matcher(url);
                if(url_matcher.matches()){
                    fakeBody = GetFakeResponse('oauthsuccess');
                }
                Pattern userinfo_match = Pattern.compile(baseUrl + '/users/email/.*');
                Matcher userinfo_matcher = userinfo_match.matcher(url);
                if(userinfo_matcher.matches()){
                    fakeBody = GetFakeResponse('useremailinfo');
                }
                Pattern userloginset_match = Pattern.compile('/users/id/[0-9]+/login/set');
                Matcher userloginset_matcher = userloginset_match.matcher(url);
                if(userloginset_matcher.matches()){
                    fakeBody = GetFakeResponse('setuserlogin');
                }
                response.setBody(fakeBody);
                response.setStatusCode(200);
            }else{
                response = http.send(request);    
            }
        }catch(System.CalloutException ex){}
        return response;
    }

    // updating Lithium blogs subscription for particular user
    private static void ManageSubscriptions(String session_key, String action){
        String endpoint_SiteStatus = baseUrl + '/boards/id/SiteStatus/subscriptions/users/self/add';
        String endpoint_EnterpriseBulletin = baseUrl + '/boards/id/EnterpriseBulletin/subscriptions/users/self/add';
        if(action == 'revoke'){
            endpoint_SiteStatus = baseUrl + '/boards/id/SiteStatus/subscriptions/users/self/type/email/remove';
            endpoint_EnterpriseBulletin = baseUrl + '/boards/id/EnterpriseBulletin/subscriptions/users/self/type/email/remove';
        }
        String method = 'POST';
        String[] headers = new List<String>();
        String[] params = new List<String>();
        if(action == 'grant'){
            params.add('subscription.type:email');
        }
        params.add('restapi.session_key:'+session_key);
        params.add('xslt:json.xsl');
        HttpResponse response = CallRestService(endpoint_SiteStatus, method, params, headers);
        HttpResponse response1 = CallRestService(endpoint_EnterpriseBulletin, method, params, headers);
        if (response.getStatusCode() == 200) { }
    }

    static integer counter = 0;

    // Set login name for particular user id
    private static void SetLoginName(String user_id){
        if(String.isEmpty(admin_session_key)){
            SetAdminToken();    
        }
        if(!String.isEmpty(admin_session_key)){
            String endpoint = baseUrl + '/users/id/'+user_id+'/login/set';
            String method = 'POST';
            String[] headers = new List<String>();
            String[] params = new List<String>();
            params.add('value:'+display_name);
            params.add('restapi.session_key:'+admin_session_key);
            params.add('xslt:json.xsl');
            HttpResponse response = CallRestService(endpoint, method, params, headers);
            if (response.getStatusCode() == 200) {
                LithiumAuthResponse sessionObject = (LithiumAuthResponse)JSON.deserialize(response.getBody(), LithiumAuthResponse.class);
                if(sessionObject.response.status == 'error' && sessionObject.response.error.code == '100'){
                    if(counter < 5){
                        SetDisplayName();
                        SetLoginName(user_id);
                        counter ++;
                    }
                }
            }
        }
    }

    // setting admin session token for making Lithium REST APIs
    private static void SetAdminToken(){
        String endpoint = baseUrl + '/authentication/sessions/login';
        String method = 'POST';
        String[] headers = new List<String>();
        String[] params = new List<String>();
        params.add('user.login:'+GetMapValue('CommunityAdminLogin'));
        params.add('user.password:'+GetMapValue('CommunityAdminPassword'));
        params.add('xslt:json.xsl');
        HttpResponse response = CallRestService(endpoint, method, params, headers);
        if (response.getStatusCode() == 200) {
            String response_token = response.getBody().replace('"$":','"dollar":');
            LithiumAuthResponse sessionObject = (LithiumAuthResponse)JSON.deserialize(response_token, LithiumAuthResponse.class);
            admin_session_key = sessionObject.response.value.dollar;
        }
    }

    // setting Lithium session key using ysi sso token
    private static void SetSessionToken(String authToken, String action){
        String endpoint = baseUrl + '/authentication/sessions/login';
        String method = 'POST';
        String[] headers = new List<String>();
        String[] params = new List<String>();
        params.add('sso.authentication_token:'+authToken);
        params.add('xslt:json.xsl');
        HttpResponse response = CallRestService(endpoint, method, params, headers);
        if (response.getStatusCode() == 200) {
            String response_token = response.getBody().replace('"$":','"dollar":');
            LithiumAuthResponse sessionObject = (LithiumAuthResponse)JSON.deserialize(response_token, LithiumAuthResponse.class);
            if(sessionObject.response.status == 'success'){
                user_session_key = sessionObject.response.value.dollar;
                if(SessionUser_Info == null || String.isEmpty(SessionUser_Info.login) || String.isEmpty(SessionUser_Info.id)){
                    SetUserInfo(user_session_key);
                }
                String user_id = SessionUser_Info.id;
                String user_login = SessionUser_Info.login;
                if(String.isEmpty(user_login)){
                    SetLoginName(user_id);    
                }
                ManageUserRole(user_id,'ADM',action);
                ManageSubscriptions(user_session_key,action);
            }else{
                if(sessionObject.response.error.code == '302'){
                    System.debug('Callout error - SetSessionToken: ' + sessionObject.response.error.message);
                }
            }
        } else {
          System.debug('Callout failed - SetSessionToken: ' + response.getBody());
        }
    }

    
    // setting Lithim user info
    private static void SetUserInfo(String session_key){
        if(SessionUser_Info == null){
            SessionUser_Info = new SessionUserInfo();
        }
        String endpoint = baseUrl + '/authentication/sessions/current/user';
        String method = 'POST';
        String[] headers = new List<String>();
        String[] params = new List<String>();
        params.add('restapi.session_key:'+session_key);
        params.add('xslt:json.xsl');
        HttpResponse response = CallRestService(endpoint, method, params, headers);
        if (response.getStatusCode() == 200) {
            String response_string = response.getBody().replace('"$":','"dollar":');
            LithiumUserInfoResponse UserObject = (LithiumUserInfoResponse)JSON.deserialize(response_string, LithiumUserInfoResponse.class);
            if(!String.isEmpty(String.valueof(UserObject.response.user.id.dollar))){
                SessionUser_Info.id = String.valueof(UserObject.response.user.id.dollar);
            }    
            if(!String.isEmpty(String.valueof(UserObject.response.user.login.dollar))){
                SessionUser_Info.login = String.valueof(UserObject.response.user.login.dollar);
            }    
        } else {
          System.debug('Callout failed - SetUserInfo: ' + response.getBody());
        }
    }

    // retrieving user info from email
    private static String GetUserInfoFromEmail(String admin_session, String email, String key){
        String endpoint = baseUrl + '/users/email/'+email;
        String method = 'POST';
        String[] headers = new List<String>();
        String[] params = new List<String>();
        params.add('restapi.session_key:'+admin_session);
        params.add('xslt:json.xsl');
        HttpResponse response = CallRestService(endpoint, method, params, headers);
        if (response.getStatusCode() == 200) {
            String response_string = response.getBody().replace('"$":','"dollar":');
            LithiumUserInfoResponse UserObject = (LithiumUserInfoResponse)JSON.deserialize(response_string, LithiumUserInfoResponse.class);
            if(key == 'id'){
                if(!String.isEmpty(String.valueof(UserObject.response.user.id.dollar))){
                    return String.valueof(UserObject.response.user.id.dollar);
                }    
            }
            if(key == 'login'){
                if(!String.isEmpty(String.valueof(UserObject.response.user.login.dollar))){
                    return String.valueof(UserObject.response.user.login.dollar);
                }    
            }
        } else {
          System.debug('Callout failed - GetUserInfoFromEmail: ' + response.getBody());
        }
        return '';
    }

    // adding or removing user role to particular user id
    private static void ManageUserRole(String id, String role, String action){
        if(String.isEmpty(admin_session_key)){
            SetAdminToken();    
        }
        if(!String.isEmpty(admin_session_key)){
            String endpoint = baseUrl + '/roles/name/'+role+'/users/add';
            if(action == 'revoke'){
                endpoint = baseUrl + '/roles/name/'+role+'/users/remove';
            }
            String method = 'POST';
            String[] headers = new List<String>();
            String[] params = new List<String>();
            params.add('role.user:id/'+id);
            params.add('restapi.session_key:'+admin_session_key);
            params.add('xslt:json.xsl');
            String session_key = '';
            HttpResponse response = CallRestService(endpoint, method, params, headers);
            if (response.getStatusCode() == 200) {
            }
        }
    }

    // check user exist in Lithium or not
    private static boolean UserExistinLithium(String email){
        if(String.isEmpty(admin_session_key)){
            SetAdminToken();    
        }
        if(!String.isEmpty(admin_session_key)){
            String endpoint = baseUrl + '/users/email/'+email;
            String method = 'POST';
            String[] headers = new List<String>();
            String[] params = new List<String>();
            params.add('user.email:'+email);
            params.add('restapi.session_key:'+admin_session_key);
            params.add('xslt:json.xsl');
            String session_key = '';
            HttpResponse response = CallRestService(endpoint, method, params, headers);
            if (response.getStatusCode() == 200) {
                LithiumAuthResponse sessionObject = (LithiumAuthResponse)JSON.deserialize(response.getBody(), LithiumAuthResponse.class);
                if(sessionObject.response.status != 'error'){
                    return true;
                }else{
                    if(sessionObject.response.error.code == '101'){
                        return false;                    
                    }
                }
            }
        }
        return false;
    }

    // removing special characters from email
    private static String RemoveSpecialChars(String text){
        Pattern special_chars = Pattern.compile('[~!@#$%^*()_?:-]');
        text = special_chars.matcher(text).replaceAll('');
        text = text.replace('.','');
        return text;
    }

    // settings display name from email appending the current date
    private static void SetDisplayName(){
        String displayName = user_email.substringBefore('@');
        Date today = Date.today();
        displayName = RemoveSpecialChars(displayName);
        if(displayName.length() > 11){
            displayName = displayName.substring(0,11);
        }
        display_name = displayName + (String.valueOf(today.month()).length() == 1?'0'+String.valueOf(today.month()):String.valueOf(today.month()))+(String.valueOf(today.day()).length()==1?'0'+String.valueOf(today.day()):String.valueOf(today.day()));
    }

    // future call to start the rest API calls to update the YSI Lithium community user
    @future (callout=true)
    public static void RESTService(String url, String method, String email, String[] headers, String action){
        user_email = email;
        if(String.isEmpty(admin_session_key)){
            SetAdminToken();    
        }
        if(UserExistinLithium(email)){
            display_name = GetUserInfoFromEmail(admin_session_key, email, 'login');
            if(display_name == null || String.isEmpty(display_name)){
                SetDisplayName();
            }
        }else{
            SetDisplayName();
        }
        String[] params = new List<String>();
        params.add('email:'+email);
        params.add('login:'+display_name);
        HttpResponse response = CallRestService(url, method, params, headers);
        if (response.getStatusCode() == 200) {
            SSoAuthResponse oauthResponseObj = (SSoAuthResponse)JSON.deserialize( response.getBody(), SSoAuthResponse.class);
            if(oauthResponseObj.lithiumAuthToken != null){
                SetSessionToken(oauthResponseObj.lithiumAuthToken, action);
            }else{
                if(oauthResponseObj.errorStatus != null){
                    System.debug('Callout error - RESTService: ' + oauthResponseObj.errorStatus.message);
                }
            }
        } else {
          System.debug('Callout failed - RESTService: ' + response.getBody());
        } 
    }
}