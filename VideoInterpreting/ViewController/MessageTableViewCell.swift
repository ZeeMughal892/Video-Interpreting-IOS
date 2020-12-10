//
//  MessageTableViewCell.swift
//  VideoInterpreting
//
//  Created by Muhammad Zeeshan on 08/12/2020.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    let messageLabel = UILabel()
    let bubbleBackgroundView = UIView()
    let name = UILabel()
        
    var leadingConstraintMesg: NSLayoutConstraint!
    var trailingConstraintMesg: NSLayoutConstraint!
    
    var leadingConstraintName: NSLayoutConstraint!
    var trailingConstraintName: NSLayoutConstraint!
    
    
    var chatMessage: Message! {
        didSet {
            bubbleBackgroundView.backgroundColor = chatMessage.isIncoming ? UIColor.init(named: "colorLeftMenu") : UIColor.init(named: "colorPrimaryDark")
            messageLabel.text = chatMessage.text
            name.text = chatMessage.name
            
            messageLabel.textColor = .white
            messageLabel.font = .systemFont(ofSize: 12.0)
            messageLabel.numberOfLines = 0
            messageLabel.translatesAutoresizingMaskIntoConstraints = false
            
            name.textColor = UIColor.init(named: "colorPrimaryDark")
            name.font = .boldSystemFont(ofSize: 10.0)
            name.translatesAutoresizingMaskIntoConstraints = false
                        
            if chatMessage.isIncoming {
                leadingConstraintMesg.isActive = true
                trailingConstraintMesg.isActive = false
               
                leadingConstraintName.isActive = true
                trailingConstraintName.isActive = false
                
            }else{
                leadingConstraintMesg.isActive = false
                trailingConstraintMesg.isActive = true
                
                leadingConstraintName.isActive = false
                trailingConstraintName.isActive = true
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        bubbleBackgroundView.backgroundColor = UIColor.init(named: "colorPrimaryDark")
        bubbleBackgroundView.layer.cornerRadius = 16
        bubbleBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(bubbleBackgroundView)
        addSubview(name)
        addSubview(messageLabel)
      
        
        let constraints = [
            messageLabel.topAnchor.constraint(equalTo: topAnchor,constant: 36),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor,constant: -32),
            messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 148),
                      
            bubbleBackgroundView.topAnchor.constraint(equalTo: messageLabel.topAnchor,constant: -16),
            bubbleBackgroundView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor,constant: -16),
            bubbleBackgroundView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor,constant: 16),
            bubbleBackgroundView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor,constant: 16)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        
        leadingConstraintMesg = messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 32)
        leadingConstraintMesg.isActive = false
        
        trailingConstraintMesg = messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor,constant: -32)
        trailingConstraintMesg.isActive = true
        
        
        leadingConstraintName = name.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 24)
        leadingConstraintName.isActive = false
        
        trailingConstraintName = name.trailingAnchor.constraint(equalTo: trailingAnchor,constant: -24)
        trailingConstraintName.isActive = true
        
        
        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   

}
