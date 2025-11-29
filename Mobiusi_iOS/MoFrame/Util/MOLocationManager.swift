//
//  MOLocationManager.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/14.
//

import Foundation
import CoreLocation

@objcMembers
class MOLocationManager: NSObject, @preconcurrency CLLocationManagerDelegate {
    // 单例模式
    @MainActor static let shared = MOLocationManager()
	var didGetData:Bool = false
    // 创建CLLocationManager实例
    private let locationManager = CLLocationManager()
    // 存储当前城市的闭包
	@objc public var latitude:Double = 0
	@objc public var longitude:Double = 0
	public var onCityUpdate: ((_ cityName:String?,_ success:Bool) -> Void)?
	@objc public  var onLocationUpdate: ((_ latitude:Double,_ longitude:Double,_ success:Bool) -> Void)?
    // 初始化
    override init() {
        super.init()
        
    }
    
    // 请求授权
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    // 开始更新位置
    func startUpdatingLocation() {
		didGetData = false
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .restricted {
			locationManager.delegate = self
			locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
			locationManager.delegate = self
			locationManager.desiredAccuracy = kCLLocationAccuracyBest
            requestAuthorization()
        }
        
		if CLLocationManager.authorizationStatus() == .denied {
			onLocationUpdate?(0,0,false)
			onCityUpdate?(nil,false)
		}
        
    }
    
    // 停止更新位置
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    // 位置更新回调
	@MainActor
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        // 调用反向地理编码方法获取城市名
		
		latitude = location.coordinate.latitude
		longitude = location.coordinate.longitude
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
			if self.didGetData == false {
				self.didGetData = true
				self.onLocationUpdate?(self.latitude,self.longitude,true)
				self.getCityName(from: location)
			}
			
		}
        stopUpdatingLocation()
    }
    
    // 定位失败回调
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("定位失败: \(error.localizedDescription)")
		onLocationUpdate?(0,0,false)
		onCityUpdate?(nil,false)
    }
    
//    // 授权状态变更回调 - 兼容iOS 13+
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        handleAuthorizationStatus()
    }
    
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        handleAuthorizationStatus()
//    }
    
    // 处理授权状态 - 兼容iOS 13+
    func handleAuthorizationStatus() {
        let status: CLAuthorizationStatus
        
        if #available(iOS 14.0, *) {
            // iOS 14+ 使用实例属性
            status = locationManager.authorizationStatus
        } else {
            // iOS 13- 使用类方法
            status = CLLocationManager.authorizationStatus()
        }
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("已获得定位权限")
            startUpdatingLocation()
        case .denied, .restricted:
            print("定位权限被拒绝或受限")
			onLocationUpdate?(0,0,false)
			onCityUpdate?(nil,false)
        case .notDetermined:
            print("定位权限尚未确定")
            requestAuthorization()
        @unknown default:
            print("未知授权状态")
        }
    }
    
    // 反向地理编码获取城市名
    func getCityName(from location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let error = error {
                print("反向地理编码失败: \(error.localizedDescription)")
                self?.onCityUpdate?(nil,false)
                return
            }
            if let placemark = placemarks?.first, let city = placemark.locality {
                // 将城市名通过闭包传递出去
                self?.onCityUpdate?(city,true)
            } else {
                self?.onCityUpdate?(nil,false)
            }
        }
    }
}
