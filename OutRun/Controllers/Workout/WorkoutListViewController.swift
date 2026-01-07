import UIKit
import CoreData
import CoreStore

class WorkoutListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ListSectionObserver, TabBarSelectionObserver {
    
    typealias ListEntityType = Workout
    
    let tableView = UITableView()
    
    var lastKnownDistanceUnit: UnitLength?
    var sortType = WorkoutListSortType.day(true) {
        didSet {
            refetchWithFilters()
        }
    }
    var filterTypes: [WorkoutListFilterType] = [] {
        didSet {
            refetchWithFilters()
        }
    }
    
    private lazy var sortItem = UIBarButtonItem(title: self.sortType.stringWithArrow, style: .plain, target: self, action: #selector(showSortController))
    
    let noDataLabel = UILabel(
        text: LS("NoData.Message"),
        textColor: .secondaryColor,
        font: .systemFont(ofSize: 16, weight: .bold),
        numberOfLines: 0,
        textAlignment: .center
    )
    
    private let addButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DataManager.workoutMonitor.addObserver(self)
        
        self.view.backgroundColor = .backgroundColor
        
        self.view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .backgroundColor
        tableView.separatorStyle = .none
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.navigationItem.title = LS("WorkoutListViewController.Headline", comment: "")
        
        self.tableView.addSubview(noDataLabel)
        noDataLabel.snp.makeConstraints { (make) in
            make.center.equalTo(self.tableView.safeAreaLayoutGuide)
            make.right.lessThanOrEqualToSuperview().offset(-20)
            make.left.greaterThanOrEqualToSuperview().offset(20)
        }
        self.noDataLabel.isHidden = true
        
        self.lastKnownDistanceUnit = UserPreferences.distanceMeasurementType.safeValue
        
        self.navigationItem.rightBarButtonItem = sortItem
        
        // 5. NEW: Add Button to self.view (NOT tableView)
        // This ensures it floats above the table and doesn't scroll
        self.view.addSubview(addButton)
        
        addButton.layer.cornerRadius = 29
        addButton.backgroundColor = .accentColor
        addButton.layer.borderColor = UIColor.backgroundColor.withAlphaComponent(0.2).cgColor
        addButton.layer.borderWidth = 4
        
        // Optional: Add shadow for better visibility
        addButton.layer.shadowColor = UIColor.black.cgColor
        addButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        addButton.layer.shadowOpacity = 0.3
        addButton.layer.shadowRadius = 4

        addButton.addTarget(self, action: #selector(showNewWorkoutController), for: .touchUpInside)
        
        addButton.snp.makeConstraints { (make) in
            // Pin to Safe Area of the main VIEW, not the table
            make.right.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.width.height.equalTo(58)
        }
        
        let plusIcon = UIImageView(image: .tabbarPlus)
        plusIcon.tintColor = .white
        addButton.addSubview(plusIcon)
        plusIcon.snp.makeConstraints { (make) in
            make.centerX.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }

    }
    
    deinit {
        DataManager.workoutMonitor.removeObserver(self)
    }
    
    @objc private func showNewWorkoutController() {
        let controller = NewWorkoutViewController()
        self.showDetailViewController(controller, sender: self)
    }

    func willGetSelected() {
        if lastKnownDistanceUnit != UserPreferences.distanceMeasurementType.safeValue {
            self.lastKnownDistanceUnit = UserPreferences.distanceMeasurementType.safeValue
            guard let indexPaths = self.tableView.indexPathsForVisibleRows else {
                self.tableView.reloadData()
                return
            }
            self.tableView.reloadRows(at: indexPaths, with: .none)
        }
    }

    // MARK: TableView
    
    // 6. CHANGE: Removed 'override' keyword from these methods
    func numberOfSections(in tableView: UITableView) -> Int {
        let sections = DataManager.workoutMonitor.numberOfSections()
        self.noDataLabel.isHidden = DataManager.workoutMonitor.numberOfObjects() != 0
        return sections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionCount = DataManager.workoutMonitor.numberOfObjects(safelyIn: section) else {
            return 0
        }
        return sectionCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let workout = DataManager.workoutMonitor[indexPath.section, indexPath.row]
        let cell = WorkoutListCell(workout: workout)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let workout = DataManager.workoutMonitor[indexPath.section, indexPath.row]
        
        let controller = WorkoutViewController()
        controller.workout = workout
        
        self.showDetailViewController(controller, sender: self)
        
    }
    
    // MARK: ListObserver
    
    func listMonitorWillChange(_ monitor: ListMonitor<Workout>) {
        self.tableView.beginUpdates()
    }
    
    func listMonitorDidChange(_ monitor: ListMonitor<Workout>) {
        self.tableView.endUpdates()
    }
    
    func listMonitorWillRefetch(_ monitor: ListMonitor<Workout>) {
        self.setTable(enabled: false)
    }
    
    func listMonitorDidRefetch(_ monitor: ListMonitor<Workout>) {
        self.tableView.reloadData()
        self.setTable(enabled: true)
        
    }
    
    // MARK: ListObjectObserver
    
    func listMonitor(_ monitor: ListMonitor<Workout>, didInsertObject object: Workout, toIndexPath indexPath: IndexPath) {
        self.tableView.insertRows(at: [indexPath], with: .fade)
    }
    
    func listMonitor(_ monitor: ListMonitor<Workout>, didDeleteObject object: Workout, fromIndexPath indexPath: IndexPath) {
        self.tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    func listMonitor(_ monitor: ListMonitor<Workout>, didUpdateObject object: Workout, atIndexPath indexPath: IndexPath) {
        if let cell = self.tableView.cellForRow(at: indexPath) as? WorkoutListCell {
            cell.workout = object
            cell.setup()
        }
    }
    
    func listMonitor(_ monitor: ListMonitor<Workout>, didMoveObject object: Workout, fromIndexPath: IndexPath, toIndexPath: IndexPath) {
        self.tableView.deleteRows(at: [fromIndexPath], with: .fade)
        self.tableView.insertRows(at: [toIndexPath], with: .fade)
    }
    
    // MARK: ListSectionObserver
    func listMonitor(_ monitor: ListMonitor<Workout>, didInsertSection sectionInfo: NSFetchedResultsSectionInfo, toSectionIndex sectionIndex: Int) {
        self.tableView.insertSections(IndexSet(arrayLiteral: sectionIndex), with: .fade)
    }
    
    func listMonitor(_ monitor: ListMonitor<Workout>, didDeleteSection sectionInfo: NSFetchedResultsSectionInfo, fromSectionIndex sectionIndex: Int) {
        self.tableView.deleteSections(IndexSet(arrayLiteral: sectionIndex), with: .fade)
    }
    
    // MARK: Private
    
    private func setTable(enabled: Bool) {
        tableView.isUserInteractionEnabled = enabled
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .beginFromCurrentState,
            animations: { () -> Void in
                self.tableView.alpha = enabled ? 1.0 : 0.5
            },
            completion: nil
        )
    }
    
    // MARK: Sort
    
    /// the type by which the List is supposed to be sorted including if it is supposed to be descending
    enum WorkoutListSortType: Equatable {
        
        case day(Bool)
        case distance(Bool)
        /// NOTE: Not usable because value is transient
        case duration(Bool)
        
        var descending: Bool {
            switch self {
            case .day(let desc), .distance(let desc), .duration(let desc):
                return desc
            }
        }
        
        var string: String {
            switch self {
            case .day(_):
                return LS("WorkoutList.Sort.Date")
            case .distance(_):
                return LS("WorkoutStats.Distance")
            case .duration(_):
                return LS("Workout.Duration")
            }
        }
        
        var stringWithArrow: String {
            return self.string + (self.descending ? " ↓" : " ↑")
        }
        
        var oppositeOrderedType: WorkoutListSortType {
            switch self {
            case .day(let desc):
                return .day(!desc)
            case .distance(let desc):
                return .distance(!desc)
            case .duration(let desc):
                return .duration(!desc)
            }
        }
        
        var fetchClause: FetchClause {
            switch self {
            case .day(let desc):
                return OrderBy<Workout>(desc ? .descending(\.startDate) : .ascending(\.startDate))
            case .distance(let desc):
                return OrderBy<Workout>(desc ? .descending(\.distance) : .ascending(\.distance))
            case .duration(let desc):
                return OrderBy<Workout>(desc ? .descending(\.activeDuration) : .ascending(\.activeDuration))
            }
        }
        
    }
    
    enum WorkoutListFilterType: Equatable {
        case isRace
        case type(Workout.WorkoutType)
        
        var string: String {
            switch self {
            case .isRace:
                return LS("WorkoutList.Filter.IsRace")
            case .type(_):
                return LS("Workout.Type")
            }
            
        }
        
        var workoutType: Workout.WorkoutType? {
            switch self {
            case .type(let workoutType):
                return workoutType
            default:
                return nil
            }
        }
        
        var fetchClause: Where<Workout> {
            switch self {
            case .isRace:
                return Where<Workout>(\.isRace == true)
            case .type(let type):
                return Where<Workout>(\.workoutType == type.rawValue)
            }
        }
    }
    
    @objc func showSortController(sourceView: UIBarButtonItem) {
        let sortController = WorkoutListSortViewController()
        let controller = UINavigationController(rootViewController: sortController)
        controller.modalPresentationStyle = .popover
        sortController.listController = self
        controller.preferredContentSize = CGSize(width: 250, height: 250)
        if let presentationController = controller.popoverPresentationController {
            presentationController.delegate = sortController
            presentationController.permittedArrowDirections = [.down, .up]
        }
        controller.popoverPresentationController?.barButtonItem = self.sortItem
        self.present(controller, animated: true)
    }
    
    func refetchWithFilters() {
        
        let filterClauses = filterTypes.map { (type) -> Where<Workout> in
            return type.fetchClause
        }
        
        sortItem.title = sortType.stringWithArrow
        DataManager.workoutMonitor.refetch([filterClauses.combinedByAnd(), sortType.fetchClause])
    }
    
}
