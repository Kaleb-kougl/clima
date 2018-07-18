//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
//This allows us to tap in to the GPS functionality of the iPhone
import CoreLocation
import Alamofire
import SwiftyJSON

//CLLocationManagerDelegate delegates how we handle location data
class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "a063b21a4b5a0b8d0b28d28e17d66717"
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    var farhenheitFormat : Bool = true
    

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    @IBAction func switchTempFormat(_ sender: UISwitch) {
        if (sender.isOn == true) {
            farhenheitFormat = true
        }
        else {
            farhenheitFormat = false
        }
        UIUpdateWithWeatherData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        //saying that we will deal with the location data (delegate)
        //setting the weatherviewcontroller(self) as the delegate of the location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        //gets premission from user to use their location data
        locationManager.requestWhenInUseAuthorization()
        //have to edit the plist in order for this pop to show to user
        locationManager.startUpdatingLocation()
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url: String, parameters: [String : String]){
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            //This is the closure (in keyword)
            response in //What gets triggered when the process in the background is complete
            if response.result.isSuccess {
                //print("Success! Got the weather data!")
                
                //The value comes back as a optional so we have to force unwrap it (!)
                //This is safe because we already checked to make sure that the return was successful
                let weatherJSON : JSON = JSON(response.result.value!)
                
                self.updateWeatherData(json: weatherJSON) //Have to specify self because you're in a closure (specifies to look in class)
            }
            else {
                print("Error: \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issues"
            }
        }
    }
    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json : JSON) {
        //print(json["name"], json["main"]["temp"])
        if let tempResults = json["main"]["temp"].double { //optional binding to make this request safe
        
            weatherDataModel.temperature = Int(tempResults - 273.15) //Because in Kelvin, force unwrap double? to double
            weatherDataModel.city = json["name"].stringValue
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition : weatherDataModel.condition)
        }
        else { //This makes it so if the request goes wrong with weather api then it returns error to the user
            cityLabel.text = "Error: Weather Unavailable"
        }
        
        //print("Updated weather data")
        
        UIUpdateWithWeatherData()
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func UIUpdateWithWeatherData() {
        cityLabel.text = weatherDataModel.city
        let fTemperature = (Double(weatherDataModel.temperature) * 9.0) / 5.0 + 32
        //if you want C uncomment this and comment out the other
        //temperatureLabel.text = String(weatherDataModel.temperature) + "°"
        
        //Perhaps I should put this setting in a p-list
        //additionally, move this to the change city page
        
        if (farhenheitFormat == true) {
        temperatureLabel.text = String(Int(fTemperature)) + "°"
        }
        else {
           temperatureLabel.text = String(weatherDataModel.temperature) + "°"
        }
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        
        //print("Updated the UI")
        
        //I think it I want to register additional weather conditions to the UI so that it is available to the user
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //grabs the last value of the location objects because this will be the most accurate as this continues to update
        let location = locations[locations.count - 1]
        
        if location.horizontalAccuracy > 0 { //This makes sure that we get back valid input
            
            //This will keep updating unless you stop it
            locationManager.stopUpdatingLocation()
            
            //This prevents from the code from returning multiple values while in the process of stopping the location getter
            locationManager.delegate = nil
            
            //print("longitude =  \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            
            let longitude = String(location.coordinate.longitude)
            let latitude = String(location.coordinate.latitude)
            
            //This is a dictionary
            let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
            
        }
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCity(city: String) {
        //change city to given city
        //print(city)
        let params : [String : String] = ["q" : city, "appid" : APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
        
        //print(params)
    }

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "changeCityName" {
            
            let destinationVC = segue.destination as! ChangeCityViewController
            
            destinationVC.delegate = self
        }
    }
    
    
    
    
}


