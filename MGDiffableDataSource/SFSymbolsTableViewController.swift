import UIKit

final class SFSymbolsTableViewController: UITableViewController {
    
    private lazy var dataSource = makeDataSource(tableView: tableView)
    private lazy var searchBar = UISearchBar()
    private var displayedSections = Section.allCases
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = dataSource
        
        searchBar.searchBarStyle = UISearchBar.Style.default
        searchBar.placeholder = "Search..."
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        
        refresh(with: sfsymbolsTableViewModel(text: ""))
    }
    
    func refresh(with models: [SFSymbolModel]) {
        typealias Snapshot = NSDiffableDataSourceSnapshot<Section, SFSymbolModel>
        let sections = models.availableSections.sorted(by: { $0.rawValue < $1.rawValue })
        var snapshot = Snapshot()
        snapshot.appendSections(sections)
        self.displayedSections = sections
        
        for section in sections {
            let sectionModels = models.filter { $0.section == section }
            snapshot.appendItems(sectionModels, toSection: section)
        }
        dataSource.apply(snapshot)
    }
}

extension SFSymbolsTableViewController {
    enum Section: Int, CaseIterable {
        case nature
        case gaming
        case transport
        
        var title: String {
            switch self {
            case .nature:
                return "Nature"
            case .gaming:
                return "Gaming"
            case .transport:
                return "Transport"
            }
        }
    }
    
    func makeDataSource(tableView: UITableView) -> UITableViewDiffableDataSource<Section, SFSymbolModel> {
        UITableViewDiffableDataSource(tableView: tableView, cellProvider: cellProvider)
    }
    
    func cellProvider(tableView: UITableView, indexPath: IndexPath, model: SFSymbolModel) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.title
        cell.imageView?.image = model.image
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.text = "    " + displayedSections[section].title
        label.backgroundColor = .systemGray5
        label.layoutMargins = .init(top: 0, left: 8, bottom: 0, right: 8)
        return label
    }
}

extension SFSymbolsTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange textSearched: String) {
        refresh(with: sfsymbolsTableViewModel(text: textSearched))
    }
}

func sfsymbolsTableViewModel(text: String) -> [SFSymbolModel] {
    guard !text.isEmpty else { return natureModels + transportModels + gamingModels }
    return (natureModels + transportModels + gamingModels).filter { $0.title.contains(text.lowercased()) }
}

extension SFSymbolModel {
    var section: SFSymbolsTableViewController.Section {
        if transportModels.contains(self) {
            return .transport
        } else if gamingModels.contains(self) {
            return .gaming
        } else if natureModels.contains(self) {
            return .nature
        } else {
            preconditionFailure("give models a section")
        }
    }
}

extension Array where Element == SFSymbolModel {
    var availableSections: [SFSymbolsTableViewController.Section] {
        Array<SFSymbolsTableViewController.Section>(Set(self.map(\.section)))
    }
}
