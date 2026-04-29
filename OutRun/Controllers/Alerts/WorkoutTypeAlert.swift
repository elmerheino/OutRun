//
//  WorkoutTypeAlert.swift
//
//  OutRun
//  Copyright (C) 2020 Tim Fraedrich <timfraedrich@icloud.com>
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import UIKit

class WorkoutTypeAlert: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let action: (Workout.WorkoutType) -> Void
    let manualAction: (() -> Void)?
    
    let types: [Workout.WorkoutType] = [
        .running,
        .walking,
        .hiking,
        .cycling,
        .skating,
        .crossCountrySkiing
    ]
    
    var allOptions: [String] = []
    
    let pickerView = UIPickerView()
    let generator = UISelectionFeedbackGenerator()
    
    init(action: @escaping (Workout.WorkoutType) -> Void, manualAction: (() -> Void)? = nil) {
        self.action = action
        self.manualAction = manualAction
        super.init(nibName: nil, bundle: nil)
        
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
        
        for type in types {
            allOptions.append(type.description)
        }
        if manualAction != nil {
            allOptions.append(LS("NewWorkoutAlert.EnterManually"))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        let containerView = UIView()
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 15
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        self.view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
        }
        
        let headerLabel = UILabel()
        headerLabel.text = LS("NewWorkoutAlert.Title")
        headerLabel.font = .systemFont(ofSize: 18, weight: .bold)
        headerLabel.textAlignment = .center
        
        containerView.addSubview(headerLabel)
        headerLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        containerView.addSubview(pickerView)
        pickerView.snp.makeConstraints { make in
            make.top.equalTo(headerLabel.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.height.equalTo(150)
        }
        
        let acceptButton = UIButton(type: .system)
        acceptButton.setTitle(LS("Accept"), for: .normal)
        acceptButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        acceptButton.backgroundColor = .accentColor
        acceptButton.setTitleColor(.white, for: .normal)
        acceptButton.layer.cornerRadius = 10
        acceptButton.addTarget(self, action: #selector(acceptTapped), for: .touchUpInside)
        
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle(LS("Cancel"), for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        cancelButton.backgroundColor = .systemGray5
        cancelButton.setTitleColor(.label, for: .normal)
        cancelButton.layer.cornerRadius = 10
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        
        containerView.addSubview(acceptButton)
        containerView.addSubview(cancelButton)
        
        let safeArea = self.view.safeAreaLayoutGuide
        
        acceptButton.snp.makeConstraints { make in
            make.top.equalTo(pickerView.snp.bottom).offset(10)
            make.right.equalToSuperview().offset(-20)
            make.width.equalTo(containerView.snp.width).multipliedBy(0.4)
            make.height.equalTo(44)
            make.bottom.equalTo(safeArea).offset(-10)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(pickerView.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(containerView.snp.width).multipliedBy(0.4)
            make.height.equalTo(44)
        }
    }
    
    @objc func acceptTapped() {
        let row = pickerView.selectedRow(inComponent: 0)
        if row < types.count {
            action(types[row])
        } else {
            manualAction?()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func cancelTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UIPickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return allOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return allOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        generator.selectionChanged()
    }
    
    func present(on controller: UIViewController) {
        generator.prepare()
        controller.present(self, animated: true, completion: nil)
    }
}
