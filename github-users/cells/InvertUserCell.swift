import UIKit

class InvertUserCell: UITableViewCell {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var details: UILabel!
    @IBOutlet weak var notes: UIImageView!
    
    private var imageLoader = ImageLoader()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatar.layer.borderWidth = 1
        avatar.layer.masksToBounds = false
        avatar.layer.borderColor = UIColor.black.cgColor
        avatar.layer.cornerRadius = avatar.frame.height/2
        avatar.clipsToBounds = true
        
    }
    
    func configure(user: CoreUser) {
        username.text = user.username
        details.text = user.type
        if let avatar = user.avatar {
            let image = UIImage(data: avatar)!
            let filter = CIFilter(name: "CIColorInvert")!
            filter.setValue(CIImage(image: image), forKey: kCIInputImageKey)
            let newImage = UIImage(ciImage: filter.outputImage!)
            self.avatar.image = newImage
        }
//        imageLoader.obtainImageWithPath(imagePath: user.avatarURL!) { (image) in
//            let filter = CIFilter(name: "CIColorInvert")!
//            filter.setValue(CIImage(image: image), forKey: kCIInputImageKey)
//            let newImage = UIImage(ciImage: filter.outputImage!)
//            self.avatar.image = newImage
//        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
