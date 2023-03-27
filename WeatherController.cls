public with sharing class WeatherController {
    public static final decimal kelvinValue=273.15;
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getWeatherInfo(String accountId) {
        Map<String, String> result = new Map<String, String>();
        system.debug('here');
        try {
            Account account = [SELECT BillingAddress FROM Account WHERE Id = :accountId];
            String city = account.BillingAddress.getCity();
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            String apiKey = '0a0e337a7f755a07fa9eb64f5417a47d';
            request.setEndpoint('https://api.openweathermap.org/data/2.5/weather?q=' + city + '&appid=' + apiKey);
            request.setMethod('GET');
            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() == 200) {
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                system.debug(results);
                Map<String, Object> main = (Map<String, Object>) (results.get('main'));
                List<Object> weatherList=(List<Object>)(results.get('weather'));
                Map<String, Object> weatherObj = (Map<String, Object>) weatherList.get(0);
                String description = (String) weatherObj.get('description');
                description=description.capitalize();
                String iconUrl = 'https://openweathermap.org/img/w/'+(String) weatherObj.get('icon')+ '.png';
                system.debug(iconUrl);
                String temperatureKelvin = String.valueOf(main.get('temp'));
                Decimal tempCelsius=Decimal.valueOf(temperatureKelvin)-kelvinValue;
               
                String temperature=String.valueOf(tempCelsius.intValue());
                
 
                result.put('temperature', temperature);
                result.put('description', description);
                result.put('iconUrl', iconUrl);
            } else {
                result.put('errorMessage', 'Failed to retrieve weather information for ' + city);
            }
        } catch (Exception ex) {
            result.put('errorMessage', ex.getMessage());
       }
        
        return result;
    }
    
  
    
    @AuraEnabled
    public static void updateBillingAddress(String accid, String cityparam, String streetparam, String stateparam, String postalCodeparam, String countryparam) {
        system.debug('heree');
        system.debug(cityparam);
        system.debug(accid);
        system.debug(streetparam);
        system.debug(cityparam);
        system.debug(stateparam);
        system.debug(postalCodeparam);
        system.debug(countryparam);
        Account acct = [SELECT Id, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry FROM Account WHERE Id = :accid LIMIT 1];

        acct.BillingStreet = streetparam;
        acct.BillingCity = cityparam;
        acct.BillingState = stateparam;
        acct.BillingPostalCode = postalCodeparam;
        acct.BillingCountry = countryparam;
        
        update acct;
    }

     
}