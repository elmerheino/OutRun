//
//  FullscreenChartViewController.swift
//  OutRun
//

import UIKit
import DGCharts
import SnapKit

class FullscreenChartViewController: UIViewController {
    
    let chartTitle: String
    let sections: [(color: UIColor, data: [(Measurement<Unit>, Measurement<Unit>)], samples: [TempWorkoutSeriesDataSampleType])]
    
    private let titleLabel = UILabel(
        textColor: .secondaryColor,
        font: .systemFont(ofSize: 16, weight: .bold)
    )
    
    private let closeButton: UIButton = {
        let btn = UIButton(type: .system)
        if #available(iOS 13.0, *) {
            btn.setImage(UIImage(systemName: "xmark"), for: .normal)
        } else {
            btn.setTitle("Close", for: .normal)
        }
        btn.tintColor = .secondaryColor
        return btn
    }()
    
    let diagram: LineChartView = {
        let chart = LineChartView()
        
        chart.backgroundColor = .backgroundColor
        chart.noDataTextColor = .secondaryColor
        chart.gridBackgroundColor = UIColor.foregroundColor.withAlphaComponent(0.5)
        chart.rightAxis.labelTextColor = .secondaryColor
        chart.xAxis.labelTextColor = .secondaryColor
        
        chart.chartDescription.enabled = false
        chart.xAxis.labelPosition = .bottom
        chart.leftAxis.enabled = false
        chart.legend.enabled = false
        
        // Allow zooming and scrolling
        chart.scaleXEnabled = true
        chart.scaleYEnabled = true
        chart.pinchZoomEnabled = true
        chart.dragEnabled = true
        chart.highlightPerTapEnabled = true
        chart.highlightPerDragEnabled = true
        
        chart.minOffset = 0
        
        return chart
    }()
    
    init(title: String, sections: [(color: UIColor, data: [(Measurement<Unit>, Measurement<Unit>)], samples: [TempWorkoutSeriesDataSampleType])]) {
        self.chartTitle = title
        self.sections = sections
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundColor
        
        titleLabel.text = chartTitle
        
        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        view.addSubview(diagram)
        
        closeButton.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.right.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.width.height.equalTo(30)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(closeButton)
            make.left.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.right.equalTo(closeButton.snp.left).offset(-10)
        }
        
        diagram.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.right.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-10)
        }
        
        setData()
    }
    
    @objc func closeView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setData() {
        var dataSets = [LineChartDataSet]()
        
        for section in sections {
            var values = [ChartDataEntry]()
            
            for (index, dataEntry) in section.data.enumerated() {
                let sample: TempWorkoutSeriesDataSampleType? = section.samples.indices.contains(index) ? section.samples[index] : nil
                let entry = ChartDataEntry(x: dataEntry.0.value, y: dataEntry.1.value, data: sample)
                values.append(entry)
            }
            
            let set = LineChartDataSet(entries: values, label: "nil")
            set.setColor(section.color as NSUIColor)
            set.lineWidth = 3
            set.drawCirclesEnabled = false
            set.drawValuesEnabled = false
            set.lineCapType = .round
            set.highlightColor = UIColor.secondaryColor as! NSUIColor
            
            dataSets.append(set)
        }
        
        diagram.data = LineChartData(dataSets: dataSets)
    }
}
