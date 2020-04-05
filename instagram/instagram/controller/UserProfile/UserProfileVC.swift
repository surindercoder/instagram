//  UserProfileVC.swift
//  instagram
//  Created by surinder pal singh sidhu on 2020-02-27.
//  Copyright © 2020 surinder. All rights reserved.


import UIKit
import Firebase
private let reuseIdentifier = "Cell"


private let headerIdentifier = "UserProfileHeader"

class UserProfileVC: UICollectionViewController,UICollectionViewDelegateFlowLayout ,UserProfileHeaderDelegate {

    
 var user: User?
    //var userFromSearchVC: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        self.collectionView!.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        // Do any additional setup after loading the view.
        // background color
        self.collectionView?.backgroundColor = .white
        self.navigationItem.title = "sidhu"
        if self.user == nil {
            fetchCurrentUserData()
        }
    }
 // MARK: - UICollectionViewFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
    
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        // declare header
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! UserProfileHeader
        // set delegate
        header.delegate = self 
        
        // set the user in header
        header.user = self.user

        
        // return header
        return header
        
            }
   
        
    
    
    //MARK:
    func fetchCurrentUserData() {
      
     guard let currentUid = Auth.auth().currentUser?.uid else { return }
              
              Database.database().reference().child("users").child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
                  guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
                  let uid = snapshot.key
                  let user = User(uid: uid, dictionary: dictionary)
                  self.user = user
                  self.navigationItem.title = user.username
                  self.collectionView?.reloadData()
              }
    }
    
    func handleEditFollowTapped(for header: UserProfileHeader) {
          print("edit follow button called")
        guard let user = header.user else { return }
        
        if header.editProfileFollowButton.titleLabel?.text == "Edit Profile" {
            
//            let editProfileController = EditProfileController()
//            editProfileController.user = user
//            editProfileController.userProfileController = self
//            let navigationController = UINavigationController(rootViewController: editProfileController)
//            present(navigationController, animated: true, completion: nil)
            
        } else {
            // handles user follow/unfollow
            if header.editProfileFollowButton.titleLabel?.text == "Follow" {
                header.editProfileFollowButton.setTitle("Following", for: .normal)
                user.follow()
            } else {
                header.editProfileFollowButton.setTitle("Follow", for: .normal)
                user.unfollow()
            }
        }
    }
    
    func setUserStats(for header: UserProfileHeader) {
        guard let uid = header.user?.uid else { return }
               
               var numberOfFollwers: Int!
               var numberOfFollowing: Int!
               
               // get number of followers
               USER_FOLLOWER_REF.child(uid).observe(.value) { (snapshot) in
                   if let snapshot = snapshot.value as? Dictionary<String, AnyObject> {
                       numberOfFollwers = snapshot.count
                   } else {
                       numberOfFollwers = 0
                   }
                   
                   let attributedText = NSMutableAttributedString(string: "\(numberOfFollwers!)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
                   attributedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
                   
                   header.followersLabel.attributedText = attributedText
               }
               
               // get number of following
               USER_FOLLOWING_REF.child(uid).observe(.value) { (snapshot) in
                   if let snapshot = snapshot.value as? Dictionary<String, AnyObject> {
                       numberOfFollowing = snapshot.count
                   } else {
                       numberOfFollowing = 0
                   }
                   
                   let attributedText = NSMutableAttributedString(string: "\(numberOfFollowing!)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
                   attributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
                   
                   header.followingLabel.attributedText = attributedText
               }
               
               // get number of posts
               USER_POSTS_REF.child(uid).observeSingleEvent(of: .value) { (snapshot) in
                   guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else { return }
                   let postCount = snapshot.count
                   
                   let attributedText = NSMutableAttributedString(string: "\(postCount)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
                   attributedText.append(NSAttributedString(string: "posts", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
                   
                   header.postsLabel.attributedText = attributedText
               }
    }
    
    func handleFollowersTapped(for header: UserProfileHeader) {
        let followVC = FollowLikeVC()
        //followVC.viewingMode = FollowLikeVC.ViewingMode(index: 1)
      followVC.uid = user?.uid
        followVC.isFollower = true
        followVC.isFollowing = false
        navigationController?.pushViewController(followVC, animated: true)
    }
    
    func handleFollowingTapped(for header: UserProfileHeader) {
        let followVC = FollowLikeVC()
      //  followVC.viewingMode = FollowLikeVC.ViewingMode(index: 0)
       followVC.uid = user?.uid
        followVC.isFollowing = true
        followVC.isFollower = false
        navigationController?.pushViewController(followVC, animated: true)
    }
    
}