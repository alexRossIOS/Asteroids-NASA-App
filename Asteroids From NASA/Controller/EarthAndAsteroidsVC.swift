//
//  ViewController.swift
//  Asteroids From NASA
//
//  Created by Алексей Россошанский on 03.11.17.
//  Copyright © 2017 Alexey Rossoshasky. All rights reserved.
//

import UIKit

class EarthAndAsteroidsVC: UIViewController {
    
    //MARK: VC VARs
    var asteroidsArray = [AsteroidModel]()
    var earthImage = UIImageView()
    //Переменная для появляющегося infoView
    var newView = InfoView()
    //MARK: Outlets
    @IBOutlet weak var datePicker: UIDatePicker!
    
    
    //MARK: Переменные для градиента и звезд (CALayer)
    var gradientLayer = CAGradientLayer()
    var starLayer = CAShapeLayer()
    
}


//MARK:  View Loads
extension EarthAndAsteroidsVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.addSublayer(starLayer)
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        addEarthOnView(view: view, imageOfEarth: earthImage)
        today()
        getAsteroidsRequest()
    }
    
    
    
    override func viewDidLayoutSubviews() {
        GradientAndStars.configGradientLayer(gradientLayer)
        gradientLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        GradientAndStars.configStarLayer(starLayer, view: self.view)
    }
    
}


//MARK: Date picker
extension EarthAndAsteroidsVC {
    @IBAction func chooseDate(_ sender: UIButton) {
        
        let date = datePicker.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        DateCreate.shared.chosenDate = dateFormatter.string(from: date)
        
        getAsteroidsRequest()
        
    }
    
}


//MARK: Request
extension EarthAndAsteroidsVC {
    
    func getAsteroidsRequest() {
        
        
        GetAsteroidsManager.getList(success: { (asteroids) in
            
            DispatchQueue.main.async { [weak self] in
                
                self?.removeSubviews(subviews: (self?.view.subviews)!)
                self?.asteroidsArray.removeAll()
                self?.asteroidsArray.append(contentsOf: asteroids)
                
                //Сheck for emptiness array of asteroids
                if self?.asteroidsArray.isEmpty == false {
                    self?.addAsteroidsOnView(asteroidsArray: (self?.asteroidsArray)!, earthImage: (self?.earthImage)!, view: (self?.view)!)
                }
            }
            
        }) { (requestError) in
            print(requestError)
        }
        
    }
}


//MARK: Current day
extension EarthAndAsteroidsVC {
    func today() {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let result = formatter.string(from: date)
        DateCreate.shared.chosenDate = result
    }
    
}


//MARK: Func to remove subviews
extension EarthAndAsteroidsVC {
    func removeSubviews(subviews: [UIView] ){
        for subUIView in subviews {
            if subUIView.tag != 70 && subUIView.tag != 71 && subUIView.tag != 72 {
                subUIView.removeFromSuperview()
            }
        }
        
    }
}


extension EarthAndAsteroidsVC {
    
    //MARK: Функция добавляющая image земли
    func addEarthOnView(view: UIView, imageOfEarth: UIImageView){
        
        imageOfEarth.translatesAutoresizingMaskIntoConstraints = false
        imageOfEarth.image = #imageLiteral(resourceName: "earth")
        //Добавляем тег, чтобы не делать remove изображения земли
        imageOfEarth.tag = 72
        
        //Для анимации(сначала размер нулевой)
        imageOfEarth.transform = CGAffineTransform(scaleX: 0, y: 0)
        
        view.addSubview(imageOfEarth)
        
        UIView.animate(withDuration: 2.6, delay: 0.5, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            imageOfEarth.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: nil)
        
        //Констрейнты
        let heightConstraint = imageOfEarth.heightAnchor.constraint(equalToConstant: view.frame.height)
        let widthConstraint = imageOfEarth.widthAnchor.constraint(equalToConstant: view.frame.height)
        let xPlacement = imageOfEarth.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: (-(view.frame.height/2)))
        let yPlacement = imageOfEarth.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        let constraints = [heightConstraint, widthConstraint, xPlacement, yPlacement]
        NSLayoutConstraint.activate(constraints)
    }
    
    
    //MARK: Функция добавляющая imageViews астероидов
    func addAsteroidsOnView(asteroidsArray: [AsteroidModel], earthImage: UIImageView, view: UIView) {
        
        //Переменная размера астероида
        var asteroidSize = CGFloat(0)
        
        //Определяем самый большой размер астероида (по среднему оцененному размеру)
        let maxSize = asteroidsArray.map{ $0.averageOfestimatedDiametr }.max()!
        
        //Рассчитываем расстояние от максимального X земли до правой границы экрана (-50 сделал чтобы не было сильно прижато к правой границе экрана)
        let distanceBetweenMaxXofEarthAndRightBorder = view.frame.width - earthImage.frame.maxX - 50
        
        //Накапливающая переменная, для пропорционального изменения расположения астероидов
        var cosmos = CGFloat(0)
        
        //Для назначения тега каждому imageView
        var tag = 0
        
        for asteroid in asteroidsArray {
            
            let imageOfAsteroid = UIImageView()
            imageOfAsteroid.translatesAutoresizingMaskIntoConstraints = false
            
            //Ставим картинку астероидам (поскольку 3 типа картинок (маленький, средний и большой) коэффициент 1/3)
            switch asteroid.averageOfestimatedDiametr {
            case 0...(maxSize*1/3): imageOfAsteroid.image = #imageLiteral(resourceName: "asteroid1")
            case (maxSize*1/3)...(maxSize*2/3): imageOfAsteroid.image = #imageLiteral(resourceName: "asteroid2")
            default: imageOfAsteroid.image = #imageLiteral(resourceName: "asteroid3")
            }
            
            //Устанавливаем размер астероида (самая простая пропорция) пропорционально земле (диаметр земли 12742000 метров, а поскольку диаметры астероидов много меньше, уменьшим диаметр земли в 1000 раз и относительно этой цифры найдем пропорциональные размеры, иначе астероиды будут на столько малы, что кликнуть на них не получится)
            asteroidSize = CGFloat(asteroid.averageOfestimatedDiametr * Double(earthImage.frame.width) / Constant.App_const.diameterOfEatrhInMeters)
            
            //Для анимации(сначала размер нулевой)
            imageOfAsteroid.transform = CGAffineTransform(scaleX: 0, y: 0)
            
            //Добавляем картинку на вью
            view.addSubview(imageOfAsteroid)
            
            //Констрейнты
            //базовые (по линии и размер)
            let heightConstraint = imageOfAsteroid.heightAnchor.constraint(equalToConstant: asteroidSize)
            let widthConstraint = imageOfAsteroid.widthAnchor.constraint(equalToConstant: asteroidSize)
            let yPlacement = imageOfAsteroid.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            
            //К накапливающей переменной добавляем размер n-ого астероида
            cosmos = cosmos + asteroidSize
            
            //Отдаляем крайний астероид на максимальное расстояние с учетом его размеров
            let collocation = distanceBetweenMaxXofEarthAndRightBorder - cosmos
            
            let xPlacement = imageOfAsteroid.leadingAnchor.constraint(equalTo: earthImage.trailingAnchor, constant: collocation)
            
            let constraints = [heightConstraint, widthConstraint,xPlacement, yPlacement]
            NSLayoutConstraint.activate(constraints)
            
            //К накапливающей переменной добавим расстояние (от земли) поделенное на 3000000 для удобства
            cosmos = cosmos + CGFloat(asteroid.missDistanceKM/3000000)
            
            //Анимация появления астероида
            UIView.animate(withDuration: 0.6, delay: 0.5, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                imageOfAsteroid.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
            
            
            //назначаем Тэг
            imageOfAsteroid.tag = tag
            
            //Для появления информации при нажатии на астероид
            let tapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
            imageOfAsteroid.isUserInteractionEnabled = true
            imageOfAsteroid.addGestureRecognizer(tapGestureRecognizer)
            
            tag = tag + 1
        }
        view.layoutIfNeeded()
    }
    
    
    
    //MARK: Taп
    @objc  func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        
        let tappedImage = tapGestureRecognizer.view!
        
        //Нажимаем тап , и отпускаем тап
        if tapGestureRecognizer.state == .ended {
            
            self.removeSubviews(subviews: [newView])
            tappedImage.layer.borderWidth = 0
            
        } else if tapGestureRecognizer.state == .began {
            
            //Подсветим астероид при нажатии
            tappedImage.layer.masksToBounds = false
            tappedImage.clipsToBounds = true
            tappedImage.layer.cornerRadius = tappedImage.frame.height/2
            tappedImage.layer.borderColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
            tappedImage.layer.borderWidth = 1
            
            //Заполняем infoView
            
            let yCoord = tappedImage.frame.midY + tappedImage.frame.height/2 + 15
            let width = UIScreen.main.bounds.width/3
            let height = UIScreen.main.bounds.height/4
            
            //Если infoView рядом с границей, то прижмем её правый край к ней
            var xCoord = CGFloat()
            let distanceToBorder = UIScreen.main.bounds.width - tappedImage.frame.midX
            switch distanceToBorder{
            case 0 ... width/2: xCoord = UIScreen.main.bounds.width - width
            default: xCoord = tappedImage.frame.midX - UIScreen.main.bounds.width/6
            }
            
            newView = InfoView(frame: CGRect(x: xCoord , y: yCoord, width: width, height: height))
            
            newView.nameLabel.text = "Name: \(asteroidsArray[tappedImage.tag].name)"
            newView.minDiamLabel.text = "Min. Size: \(Int(asteroidsArray[tappedImage.tag].minEstimatedDiameterMeters)) М."
            newView.maxDiamLabel.text = "Max. Size: \(Int(asteroidsArray[tappedImage.tag].maxEstimatedDiameterMeters)) М."
            newView.distanceLabel.text = "Distance: \(Int(asteroidsArray[tappedImage.tag].missDistanceKM)) КМ."
            
            //Для анимации
            newView.transform = CGAffineTransform(scaleX: 0, y: 0)
            
            self.view.addSubview(newView)
            
            UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseOut], animations: {
                self.newView.transform = CGAffineTransform(scaleX: 1, y: 1)
                
            })
        }
    }
}


