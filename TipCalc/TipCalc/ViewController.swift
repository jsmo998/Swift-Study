//
//  ViewController.swift
//  TipCalc
//
//  Created by Judith Smolenski on 20/09/2023.
//


import UIKit

class ViewController: UIViewController {
    // the outlets below connect UI components to the controller
    @IBOutlet weak var billAmountLabel: UILabel!
    @IBOutlet weak var customTipPercentLabel1: UILabel!
    @IBOutlet weak var customTipPercentageSlider: UISlider!
    @IBOutlet weak var total15Label: UILabel!
    @IBOutlet weak var customTipPercentLabel2: UILabel!
    @IBOutlet weak var tipCustomLabel: UILabel!
    @IBOutlet weak var totalCustomLabel: UILabel!
    @IBOutlet weak var tip15Label: UILabel!
    @IBOutlet weak var inputTextField: UITextField!
    let tip15Percent: Float = 0.15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set up input text field and sliders on apps homescreen
        inputTextField.becomeFirstResponder()
        calculateTip(customTipPercentageSlider as Any)
    }

    @IBAction func calculateTip(_ sender: Any) {
        // function to calculate tip based on slider value and changes
        let customPercent = customTipPercentageSlider.value.rounded() / 100
        if sender is UISlider
            // if slider is altered do:
        {
            customTipPercentLabel1.text = customPercent.formatAsPercent()
            customTipPercentLabel2.text = customTipPercentLabel1.text
        }
        
        if let inputString = inputTextField.text, !inputString.isEmpty
            // if ther is an input string of billAmount do:
        {
            let billAmount = Float(inputString)!
            if sender is UITextField
                // update tip labels and calculations according to slider value
            {
                billAmountLabel.text = " " + billAmount.formatAsCurrency()
                let fifteenTip = billAmount * tip15Percent
                tip15Label.text = fifteenTip.formatAsCurrency()
                total15Label.text = (billAmount + fifteenTip).formatAsCurrency()
            }
            let customTip = billAmount * customPercent
            tipCustomLabel.text = customTip.formatAsCurrency()
            totalCustomLabel.text = (billAmount + customTip).formatAsCurrency()
        }
        else
        {
            billAmountLabel.text = ""
            tip15Label.text = ""
            total15Label.text = ""
            tipCustomLabel.text = ""
            totalCustomLabel.text = ""
        }
    }
}

// extenstion to the Float struct to include custom methods to use in this app
extension Float
{
    func formatAsCurrency() -> String {
        // turn num to currency
        return NumberFormatter.localizedString(from: NSNumber(value: self), number: NumberFormatter.Style.currency)
    }
    
    func formatAsPercent() -> String {
        // turn num to percent
        return NumberFormatter.localizedString(from: NSNumber(value: self), number: NumberFormatter.Style.percent)
    }
}
