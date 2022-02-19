//
//  MainViewController.swift
//  daum-postcode
//
//  Created by haanwave on 2022/02/19.
//

import UIKit

struct PostCode {
    static var zipcode: String?
    static var adderss: String?
}

class MainViewController: UIViewController {
    @IBOutlet weak var zipcodeField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var detailAddressField: UITextField!
    @IBOutlet weak var searchPostcodeButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        zipcodeField.text = PostCode.zipcode
        addressField.text = PostCode.adderss
    }
}

// MARK: - Configure
private extension MainViewController {
    func configureView() {
        searchPostcodeButton.layer.cornerRadius = 5.0
    }
}
