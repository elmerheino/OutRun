//
//  LabelledWorkoutTypeView.swift
//
//  OutRun
//
//  Created by GitHub Copilot.
//

import UIKit

class LabelledWorkoutTypeView: UIControl, SmallStatView {
    
    var type: Workout.WorkoutType {
        didSet {
            self.informationLabel.text = self.type.description
        }
    }
    
    private let headlineLabel = UILabel(
        textColor: .secondaryColor,
        font: .systemFont(ofSize: 14, weight: .bold)
    )
    
    private let informationLabel = UILabel(
        text: "--",
        font: .systemFont(ofSize: 25, weight: .heavy)
    )
    
    private let dropdownIcon: UIImageView = {
        let view: UIImageView
        if #available(iOS 13.0, *) {
            view = UIImageView(image: UIImage(systemName: "chevron.down"))
        } else {
            view = UIImageView() // Fallback
        }
        view.tintColor = .label
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    init(type: Workout.WorkoutType) {
        self.type = type
        super.init(frame: .zero)
        
        self.headlineLabel.text = LS("Workout.Type").uppercased()
        self.informationLabel.text = self.type.description
        
        self.addSubview(headlineLabel)
        self.addSubview(informationLabel)
        self.addSubview(dropdownIcon)
        
        headlineLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        informationLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.headlineLabel.snp.bottom)
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        dropdownIcon.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.informationLabel.snp.centerY)
            make.left.equalTo(self.informationLabel.snp.right).offset(5)
            make.right.lessThanOrEqualToSuperview()
            make.width.height.equalTo(15)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
