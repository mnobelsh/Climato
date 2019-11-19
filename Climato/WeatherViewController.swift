import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON


class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityName {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    /***Get your own App ID at https://openweathermap.org/appid ****/
    


    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    

    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var backgroundView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    

    func getWeatherData (url : String , parameter : [String:String]){
        
        Alamofire.request (url, method: .get, parameters : parameter).responseJSON {
            response in
            
            if response.result.isSuccess {
                
                let weatherJSON : JSON = JSON (response.result.value!)
                print ("Success!")
                print (weatherJSON)
                
                self.updateWeatherData(json : weatherJSON)
                
            }else{
                
                print (response.result.isFailure)
                self.cityLabel.text = "Connection Issues"
                
            }
        
        }
        
    }
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   

    func updateWeatherData(json : JSON){
        
        if let temperature = json["main"]["temp"].double {
        
        weatherDataModel.temperature = String(Int(temperature - 273.15))+"°"
        weatherDataModel.city = json["name"].stringValue
        weatherDataModel.condition = json["weather"][0]["id"].intValue
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
        weatherDataModel.description = json["weather"][0]["description"].stringValue
            
        
            
        updateUIWithWeatherData()
            
        }else{
            cityLabel.text = "City Not Found"
            descriptionLabel.text = ""
            temperatureLabel.text = ""
        }
        
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    

    func updateUIWithWeatherData() {
        
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        descriptionLabel.text = weatherDataModel.description
        backgroundView.image = UIImage(named: weatherDataModel.updateBackgroundImage(city: weatherDataModel.city))
        
    }
    
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count-1]
        
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            print ("latitude : \(location.coordinate.latitude) | longitude : \(location.coordinate.longitude)")
            
            let lat = String(location.coordinate.latitude)
            let lon = String(location.coordinate.longitude)
            
            let params : [String : String] = ["lat" : lat,"lon" : lon, "appid" : APP_ID]
            
            getWeatherData (url : WEATHER_URL, parameter : params)
            
        }
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print (error)
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    

    func UserEnterCityName(city: String) {
        
        let params : [String:String] = ["q" : city, "appid" : APP_ID]
        
        getWeatherData(url: WEATHER_URL, parameter: params)
        
    }

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            
            let destination = segue.destination as! ChangeCityViewController
            
            destination.delegate = self
            
            
        
        }
        
    }
    
    

}


