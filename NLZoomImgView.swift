//
//  NLZoomImgView.swift
//  NLSupplyChain
//
//  Created by DoubleK on 2020/12/17.
//

import UIKit

class NLZoomImgView: UIImageView {
    
    private var _scrollView: UIScrollView?
    private var _fullImageView: UIImageView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        _initTap()
    }
    
    /// 若要支持xib，则需重写此方法，且需这样重写
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        _initTap()
    }
}

private extension NLZoomImgView {
    func _initTap() {
        //单击放大
        let tap = UITapGestureRecognizer(target: self, action: #selector(zoomInAction))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }
    
    @objc func zoomInAction() {
        if _scrollView == nil {
            _scrollView = UIScrollView(frame: UIScreen.main.bounds)
            _scrollView?.showsVerticalScrollIndicator = false
            _scrollView?.showsHorizontalScrollIndicator = false
            _scrollView?.delegate = self
            
            //设置缩放系数
            _scrollView?.minimumZoomScale = 1.0
            _scrollView?.maximumZoomScale = 2.0
            window?.addSubview(_scrollView!)
            
            //双击放大/缩小
            let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction))
            doubleTap.numberOfTouchesRequired = 1
            doubleTap.numberOfTapsRequired = 2
            _scrollView?.addGestureRecognizer(doubleTap)
            
            //单击恢复原图
            let singleTap = UITapGestureRecognizer(target: self, action: #selector(zoomOutAction))
            _scrollView?.addGestureRecognizer(singleTap)
            singleTap.require(toFail: doubleTap)
        }
        
        if _fullImageView == nil {
            _fullImageView = UIImageView(frame: .zero)
            _fullImageView?.contentMode = .scaleAspectFit
            _fullImageView?.image = self.image
            _scrollView?.addSubview(_fullImageView!)
        }
        
        //放大效果
        let rect = convert(self.bounds, to: _scrollView)
        _fullImageView?.frame = rect
        
        UIView.animate(withDuration: 0.5, animations: {
            
            guard let scrollView = self._scrollView, let fullImgView = self._fullImageView else { return }
            
            scrollView.backgroundColor = UIColor.init(white: 0.0, alpha: 0.377)
            let hei = fullImgView.image?.size.height
            let wid = fullImgView.image?.size.width
            
            guard let h = hei, let w = wid, h > 0, w > 0 else { return }
            let x_Scale = w/scrollView.frame.width
            let y_Scale = h/scrollView.frame.height
            
            var newFrame = CGRect.zero
            if x_Scale >= y_Scale {
                newFrame = CGRect(x: 0, y: (scrollView.frame.height - h/x_Scale)/2.0, width: w/x_Scale, height: h/x_Scale)
            } else {
                newFrame = CGRect(x: (scrollView.frame.width - w/y_Scale)/2.0, y: 0, width: w/y_Scale, height: h/y_Scale)
            }
            self._fullImageView?.frame = newFrame
        })
    }
        
    @objc func zoomOutAction() {
        //显示状态栏
        UIView.animate(withDuration: 0.5) {
            self._fullImageView?.frame = self.convert(self.bounds, to: self._scrollView)
            self._scrollView?.backgroundColor = UIColor.clear
        } completion: { (_) in
            self._scrollView?.removeFromSuperview()
            self._scrollView = nil
            self._fullImageView = nil
        }
    }
    
    @objc func doubleTapAction() {
        guard let scrollView = _scrollView else { return }
        
        if scrollView.zoomScale > 1.0 {
            scrollView.setZoomScale(1.0, animated: true)
        } else {
            scrollView.setZoomScale(2.0, animated: true)
        }
    }
}

extension NLZoomImgView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return _fullImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        var xPoint = scrollView.center.x
        var yPoint = scrollView.center.y
        xPoint = scrollView.contentSize.width > scrollView.frame.width ? scrollView.contentSize.width/2 : xPoint
        yPoint = scrollView.contentSize.height > scrollView.frame.height ? scrollView.contentSize.height/2 : yPoint
        _fullImageView?.center = CGPoint(x: xPoint, y: yPoint)
    }
}
