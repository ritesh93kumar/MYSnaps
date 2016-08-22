class User < ActiveRecord::Base
    acts_as_voter
    
    validates :user_name, presence: true, length: { minimum: 4, maximum: 16 }  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:google_oauth2]

    has_many :posts, dependent: :destroy  
    has_many :comments, dependent: :destroy
    
    has_attached_file :avatar, styles: { medium: '152x152#' }  
validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/  
    
    has_many :notifications, dependent: :destroy
    
    has_many :follower_relationships, foreign_key: :following_id, class_name: 'Follow'
  has_many :followers, through: :follower_relationships, source: :follower

  has_many :following_relationships, foreign_key: :follower_id, class_name: 'Follow'
  has_many :following, through: :following_relationships, source: :following
    
 def self.from_omniauth(auth)
        where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
            user.email = auth.info.email
            user.password = Devise.friendly_token[0,20]
            user.name = auth.info.name
            #user.user_name = auth.info.first_name + '_' + auth.info.last_name + '_' + user.id
            user.user_name = "#{auth.info.first_name}_#{auth.info.last_name}_#{auth.uid}"
            user.avatar_file_name = auth.info.image
        end
  end
    
  def follow(user_id)  
    following_relationships.create(following_id: user_id)
  end

  def unfollow(user_id)
    following_relationships.find_by(following_id: user_id).destroy
  end
    
end
