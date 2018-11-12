//
//  EmojiPickerViewController.swift
//  EmojiPicker
//
//  Created by levantAJ on 12/11/18.
//  Copyright © 2018 levantAJ. All rights reserved.
//

import UIKit

public class EmojiPickerViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    public var sourceRect: CGRect = .zero {
        didSet {
            popoverPresentationController?.sourceRect = sourceRect
        }
    }
    public var sourceView: UIView? {
        didSet {
            popoverPresentationController?.sourceView = sourceView
        }
    }
    public var permittedArrowDirections: UIPopoverArrowDirection = .any {
        didSet {
            popoverPresentationController?.permittedArrowDirections = permittedArrowDirections
        }
    }
    public var emojiFontSize: CGFloat = 31 {
        didSet {
            emojisCollectionView?.reloadData()
        }
    }
    
    @IBOutlet weak var emojisCollectionView: UICollectionView!
    @IBOutlet weak var groupsCollectionView: UICollectionView!
    lazy var viewModel: EmojiPickerViewModelProtocol = EmojiPickerViewModel()
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        modalPresentationStyle = .popover
        popoverPresentationController?.permittedArrowDirections = permittedArrowDirections
        popoverPresentationController?.delegate = self
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

}

// MARK: - UICollectionViewDataSource

extension EmojiPickerViewController: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojisCollectionView {
            return viewModel.numberOfEmojis(section: section)
        }
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojisCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.EmojiCollectionViewCell.identifier, for: indexPath) as! EmojiCollectionViewCell
            cell.fontSize = emojiFontSize
            if let emojis = viewModel.emojis(at: indexPath) {
                cell.emojis = emojis
            }
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.GroupCollectionViewCell.identifier, for: indexPath) as! GroupCollectionViewCell
        if let group = EmojiGroup(index: indexPath.section) {
            cell.image = UIImage(named: group.rawValue, in: Bundle(for: GroupCollectionViewCell.self), compatibleWith: nil)
        }
        return cell
    }
}

extension EmojiPickerViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == emojisCollectionView {
            return CGSize(width: 37, height: 37)
        }
        return CGSize(width: 23, height: collectionView.frame.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if collectionView == emojisCollectionView {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Constant.EmojiHeaderView.identifier, for: indexPath) as! EmojiHeaderView
            if let group = EmojiGroup(index: indexPath.section) {
                headerView.title = group.name
            }
            return headerView
        }
        return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Constant.GroupHeaderView.identifier, for: indexPath)
    }
}

// MARK: - Privates

extension EmojiPickerViewController {
    private func setupViews() {
        emojisCollectionView.delegate = self
        emojisCollectionView.dataSource = self
        groupsCollectionView.delegate = self
        groupsCollectionView.dataSource = self
        
        var nib = UINib(nibName: Constant.EmojiCollectionViewCell.identifier, bundle: Bundle(for: EmojiCollectionViewCell.self))
        emojisCollectionView.register(nib, forCellWithReuseIdentifier: Constant.EmojiCollectionViewCell.identifier)
        nib = UINib(nibName: Constant.EmojiHeaderView.identifier, bundle: Bundle(for: EmojiHeaderView.self))
        emojisCollectionView.register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Constant.EmojiHeaderView.identifier)
        var layout = emojisCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.headerReferenceSize = CGSize(width: emojisCollectionView.frame.width, height: Constant.EmojiHeaderView.height)
        
        nib = UINib(nibName: Constant.GroupCollectionViewCell.identifier, bundle: Bundle(for: GroupCollectionViewCell.self))
        groupsCollectionView.register(nib, forCellWithReuseIdentifier: Constant.GroupCollectionViewCell.identifier)
        nib = UINib(nibName: Constant.GroupHeaderView.identifier, bundle: Bundle(for: GroupHeaderView.self))
        groupsCollectionView.register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Constant.GroupHeaderView.identifier)
        layout = groupsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.headerReferenceSize = CGSize(width: 0, height: 0)
        
    }
}
