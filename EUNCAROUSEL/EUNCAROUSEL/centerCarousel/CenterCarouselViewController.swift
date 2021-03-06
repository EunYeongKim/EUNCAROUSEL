//
//  CenterCarouselViewController.swift
//  EUNCAROUSEL
//
//  Created by jiyoun on 2020/11/04.
//  Ref.https://nsios.tistory.com/45

import UIKit

class CenterCarouselViewController: UIViewController {
	
	@IBOutlet weak var pageControl: UIPageControl!
	@IBOutlet weak var centerCarouselCollectionView: UICollectionView!
	
	var lastContentOffset: CGFloat = 0
	
	var cellSize: CGSize = CGSize(width: 200, height: 250)
	var previousIndex = 0
	var nowIndex = 0
	let minimumSpacing:CGFloat = 20
	let numOfCard = 6
	
	var idleTimer : Timer?
	var timeoutNumber = 0
	let timeLimit = 3
	
	override func viewDidLoad() {
		super.viewDidLoad()
		cellSize.width = centerCarouselCollectionView.frame.width - 120
		cellSize.height = centerCarouselCollectionView.frame.height
		setupCollectionView()
		setUpPageControl()
	}
	
	@IBAction func pageChanged(_ sender: Any) {
		nowIndex = pageControl.currentPage
		scrollToIndex(index: nowIndex)
	}
	
	func setUpPageControl() {
		pageControl.numberOfPages = numOfCard
		pageControl.currentPage = 0
	}
	
	func setupCollectionView() {
		cellSize.width = (view.frame.width - 2 * minimumSpacing) * 0.5
		
		let insetX = (view.bounds.width - cellSize.width) / 2.0
		
		centerCarouselCollectionView.contentInsetAdjustmentBehavior = .never
		centerCarouselCollectionView.contentInset = UIEdgeInsets(top: 0, left: insetX, bottom: 0, right: insetX)
		centerCarouselCollectionView.decelerationRate = .fast
	}
	
	func animateZoomforCell(zoomCell: UICollectionViewCell) {
		UIView.animate(
			withDuration: 0.2,
			delay: 0,
			options: .curveEaseOut,
			animations: {
				zoomCell.transform = .identity
				
			},
			completion: nil
		)
		
		
	}
	
	func animateZoomforCellremove(zoomCell: UICollectionViewCell) {
		UIView.animate(
			withDuration: 0.2,
			delay: 0,
			options: .curveEaseOut,
			animations: {
				zoomCell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8) },
			completion: nil
		)
	}
	
	func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		let cellWidthWithSpacing = cellSize.width + minimumSpacing
		var offset = targetContentOffset.pointee
		let index = (offset.x + scrollView.contentInset.left) / cellWidthWithSpacing
		let roundedIndex:CGFloat = round(index)
		
		offset = CGPoint(x: roundedIndex * cellWidthWithSpacing - scrollView.contentInset.left, y: scrollView.contentInset.top)
		targetContentOffset.pointee = offset
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let cellWidthIncludeSpacing = cellSize.width + minimumSpacing
		let offsetX = centerCarouselCollectionView.contentOffset.x
		let index = (offsetX + centerCarouselCollectionView.contentInset.left) / cellWidthIncludeSpacing
		let roundedIndex = Int(round(index))
		let indexPath = IndexPath(item: roundedIndex, section: 0)
		
		if let cell = centerCarouselCollectionView.cellForItem(at: indexPath) {
			animateZoomforCell(zoomCell: cell)
			nowIndex = roundedIndex
		}
		let beforeIndexPath = IndexPath(item: roundedIndex - 1, section: 0)
		let afterIndexPath = IndexPath(item: roundedIndex + 1, section: 0)
		
		if roundedIndex != previousIndex {
			let preIndexPath = IndexPath(item: previousIndex, section: 0)
			if let preCell = centerCarouselCollectionView.cellForItem(at: preIndexPath) {
				animateZoomforCellremove(zoomCell: preCell)
			}
			if lastContentOffset > scrollView.contentOffset.x { // move left
				if roundedIndex < 0 {
					if let moveCell = self.centerCarouselCollectionView.cellForItem(at: IndexPath(row: self.numOfCard - 1, section: 0)) {
						self.animateZoomforCell(zoomCell: moveCell)
						nowIndex = numOfCard - 1
					}
					DispatchQueue.main.async {
						let lastIndex = IndexPath(row: self.numOfCard - 1, section: 0)
						self.centerCarouselCollectionView.scrollToItem(at: lastIndex, at: .right, animated: true)
					}
				}
			}
			else {
				if roundedIndex >= numOfCard {
					if let moveCell = self.centerCarouselCollectionView.cellForItem(at: IndexPath(row: 0, section: 0)) {
						self.animateZoomforCell(zoomCell: moveCell)
						nowIndex = 0
					}
					DispatchQueue.main.async {
						let lastIndex = IndexPath(row: 0, section: 0)
						self.centerCarouselCollectionView.scrollToItem(at: lastIndex, at: .left, animated: true)
					}
				}
			}
			if beforeIndexPath.item != preIndexPath.item, let beforeCell = centerCarouselCollectionView.cellForItem(at: beforeIndexPath) {
				animateZoomforCellremove(zoomCell: beforeCell)
			}
			if afterIndexPath.item != preIndexPath.item, let afterCell = centerCarouselCollectionView.cellForItem(at: afterIndexPath) {
				animateZoomforCellremove(zoomCell: afterCell)
			}
			
		}
		previousIndex = indexPath.item
		lastContentOffset = scrollView.contentOffset.x
		pageControl.currentPage = nowIndex
	}
	
	func setTimer() {
		if let timer = idleTimer {
			//timer 객체가 nil 이 아닌경우에는 invalid 상태에만 시작한다
			if !timer.isValid {
				idleTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
			}
		}else{
			idleTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
		}
		
	}
	
	func resetTimer() {
		if let timer = idleTimer {
			if(timer.isValid){
				timer.invalidate()
			}
		}
		timeoutNumber = 0
	}
	
	@objc func timerCallback() {
		timeoutNumber += 1
		if timeoutNumber == timeLimit - 1 || timeoutNumber == timeLimit + 1 {
			nowIndex += 1
			if nowIndex >= numOfCard {
				nowIndex = 0
			}
			scrollToIndex(index: nowIndex)
		}
	}
	
	func scrollToIndex(index: Int) {
		let toIndex = IndexPath(row: index, section: 0)
		self.centerCarouselCollectionView.scrollToItem(at: toIndex, at: .right, animated: true)
		pageControl.currentPage = index
	}
}

extension CenterCarouselViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return numOfCard
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "centerCollectionViewCell", for: indexPath)
		cell.backgroundColor = UIColor.blue
		if indexPath.row != 0 {
			cell.transform =  CGAffineTransform(scaleX: 0.8, y: 0.8)
		}
		return cell
	}
	
	
	
	
}
extension CenterCarouselViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		/**카드가 새로 만들어지면 타이머를 재시작한다.*/
		resetTimer()
		setTimer()
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return minimumSpacing
	}
	
	
	
}

extension CenterCarouselViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return cellSize
	}
}
