class User < ApplicationRecord
    has_many :hosts
    has_many :remote_actions

    validates :username, presence: true, 
                         uniqueness: { case_sensitive: false }, 
                         length: { minimum: 3, maximum:25 }

    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

    validates :email, presence: true, 
                        uniqueness: true, 
                        length: { maximum:105 },
                        format: { with: VALID_EMAIL_REGEX }
    has_secure_password

end