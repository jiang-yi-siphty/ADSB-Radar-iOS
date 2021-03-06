//
//  ADSBAPIClient.swift
//  HMD
//
//  Created by Yi JIANG on 11/6/17.
//  Copyright © 2017 RobertYiJiang. All rights reserved.
//

import Foundation
import CoreLocation

enum APIRequestType{
    case post
    case put
    case get
}

final class ADSBAPIClient {
    static let sharedInstance = ADSBAPIClient()
    private init(){}
    var isFirstRoundUpdate = true
    var adsbLoction: CLLocation? {
        didSet {
            if isFirstRoundUpdate && adsbLoction != nil{
                print("isFirstRoundUpdate")
                updateAircrafts()
                isFirstRoundUpdate = false
            }
        }
    }
    var scanDistance: Float = ADSBConfig.scanRangeBase  // KM
    
    fileprivate let adsbexchangeBaseUrl = "http://public-api.adsbexchange.com/VirtualRadar/AircraftList.json"
    fileprivate var requestTimer: Timer?
    fileprivate var isLastResponseProceseed: Bool = true
    fileprivate var isUpdatingAircrafts: Bool = false
    func makeRequestUrl(with location: CLLocation, in radius: Float) -> String {
        return  "\(adsbexchangeBaseUrl)?lat=\(location.coordinate.latitude)&lng=\(location.coordinate.longitude)&fDstL=0&fDstU=\(radius)"
    }
    
    func updateLocation(_ location: CLLocation) {
        adsbLoction = location
    }
    
    func stopUpdateAircrafts(){
        requestTimer?.invalidate()
        requestTimer = nil
        isUpdatingAircrafts = false
    }
    
    func startUpdateAircrafts(every seconds: Double, range: Float){
        if isUpdatingAircrafts { return }
        ADSBConfig.scanRangeBase = range
        if requestTimer == nil {
            requestTimer =  Timer.scheduledTimer(
                timeInterval: TimeInterval(seconds),
                target      : self,
                selector    : #selector(updateAircrafts),
                userInfo    : nil,
                repeats     : true)
        } else {
            requestTimer?.fire()
        }
        isUpdatingAircrafts = true
    }
    
    @objc func updateAircrafts(){
        guard (adsbLoction != nil) else {
            print("Location has not been set")
            return
        }
        let urlString = makeRequestUrl(with: adsbLoction!, in: ADSBConfig.scanRangeBase)
        print("url string: \(urlString)")
        guard let url = URL(string: urlString) else {
            print("URL string can't be parsed")
            return
        }
        requestADSBExChange(url, handle: { (aircraftsArray, error) in
            guard error == nil else {
                print("error: \(String(describing: error))")
                return
            }
            ADSBCacheManager.sharedInstance.adsbAircrafts = aircraftsArray
        })
    }
    
    
    func requestADSBExChange(_ url: URL, handle complition: @escaping (_ aircraftsArray: [ADSBAircraft], _ error: Error?) -> Void){
        if !isLastResponseProceseed { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("value", forHTTPHeaderField: "Key")
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request, completionHandler: {data, response, error in
            if error != nil {
                print("Error from URL session data task: \(error.debugDescription)")
                return
            }
            DispatchQueue.main.async(){
                self.isLastResponseProceseed = false
                do {
                    let responseDict: [String: Any] = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
                    let adsbXResponseObj: ADSBXResponse = ADSBXResponse.init(responseDict: responseDict)!
                    guard let adsbAircrafts = adsbXResponseObj.aircraftList else { return }
                    print("Aircrafts above: \(adsbAircrafts.count)")
//                    if adsbAircrafts.count < ADSBConfig.minimumAircraftsTracking {
//                        self.scanDistance = self.scanDistance + 5
//                    } else if adsbAircrafts.count > ADSBConfig.maximumAircraftsTracking {
//                        self.scanDistance = self.scanDistance - 5
//                        if self.scanDistance < ADSBConfig.minimumScanRange {
//                            self.scanDistance = 10
//                        }
//                    }
//                    print("Next Scan range: \(self.scanDistance)")
                    complition(adsbAircrafts, nil)
                } catch let error {
                    complition([], error)
                }
                self.isLastResponseProceseed = true
                
            }
        })
        task.resume()
    }
    
    
    
}


