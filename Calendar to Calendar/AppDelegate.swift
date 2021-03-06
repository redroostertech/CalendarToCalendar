import Google
import GoogleSignIn
import UIKit
import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{
	
	var window: UIWindow?
	var service: OutlookInteractor?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
		Thread.sleep(forTimeInterval: 1.0)
		
		let notificationCenter = UNUserNotificationCenter.current()
		notificationCenter.requestAuthorization(options: [.alert, .badge, .sound], completionHandler: {(success, error) in
			if let error = error{
				print(error.localizedDescription)
			}
		})
		
		// Initialize sign-in
		var configureError: NSError?
		GGLContext.sharedInstance().configureWithError(&configureError)
		assert(configureError == nil, "Error configuring Google services: \(String(describing: configureError))")
		return true
	}
	
	func application(_ application: UIApplication,
					 open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
		if url.scheme?.lowercased() == "calendartocalendar" {
			service?.handleOAuthCallback(url: url)
			return true
		} else {
			return GIDSignIn.sharedInstance().handle(url,
													 sourceApplication: sourceApplication,
													 annotation: annotation)
		}
	}
	
	@available(iOS 9.0, *)
	func application(_ app: UIApplication, open url: URL,
					 options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
		let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String
		let annotation = options[UIApplication.OpenURLOptionsKey.annotation]
		//If it is this scheme, it is coming from Outlook
		if url.scheme?.lowercased() == "CalendarToCalendar".lowercased() {
			let newUrl = url.absoluteString.replacingOccurrences(of: "calendartocalendar", with: "CalendarToCalendar")
			service?.handleOAuthCallback(url: URL(string: newUrl)!)
			return true
		}
		//Else the scheme is coming from Google
		else {
			return GIDSignIn.sharedInstance().handle(url,
													 sourceApplication: sourceApplication,
													 annotation: annotation)
		}
	}
}

