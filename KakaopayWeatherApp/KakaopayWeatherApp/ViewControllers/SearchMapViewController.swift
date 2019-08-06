import UIKit
import MapKit

class SearchMapViewController: UIViewController, ObserverProtocol {
	
	var id = String(describing: self)
	var viewModel: ViewModel?
	var cityList = [MKMapItem]()

	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var searchBar: UISearchBar!
	
	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.delegate = self
		tableView.dataSource = self
		searchBar.delegate = self
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	@IBAction func dismiss(_ sender: Any) {
		view.endEditing(true)
		dismiss(animated: true)
	}
	
}

extension SearchMapViewController: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return view.frame.height / 12
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return cityList.count
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		saveSelectedCity(indexPath: indexPath)
		tableView.deselectRow(at: indexPath, animated: true)
		dismiss(self)
	}
	
	func saveSelectedCity(indexPath: IndexPath) {
		var savedCityList = UserDefaults.standard.array(forKey: "CityList") as? [String] ?? []
		if let selectedCity = cityList[indexPath.item].placemark.locality {
			savedCityList.append(selectedCity)
		} else {
			guard let cityName = cityList[indexPath.item].placemark.name else { return }
			savedCityList.append(cityName)
		}
		UserDefaults.standard.set(savedCityList, forKey: "CityList")
		UserDefaults.standard.synchronize()
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return configureSearchedCityCell(tableView: tableView, indexPath: indexPath)
	}
	
	func configureSearchedCityCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchedCityCell.className, for: indexPath) as? SearchedCityCell else { return UITableViewCell() }
		cell.cityNameLabel.text = cityList[indexPath.item].placemark.name
		cell.addressLabel.text = cityList[indexPath.item].placemark.title
		return cell
	}
	
}

extension SearchMapViewController: UISearchBarDelegate {
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		let localSearchRequest = MKLocalSearch.Request()
		localSearchRequest.naturalLanguageQuery = searchBar.text
		let localSearch = MKLocalSearch(request: localSearchRequest)
		localSearch.start { (localSearchResponse, error) -> Void in
			if localSearchResponse == nil { return }
			guard let mapItems = localSearchResponse?.mapItems else { return }
			self.cityList = mapItems
			self.tableView.reloadData()
		}
	}
	
}
