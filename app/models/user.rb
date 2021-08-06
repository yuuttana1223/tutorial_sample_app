class User < ApplicationRecord
  # データベースに保存する前にemail属性を強制的に小文字に変換
  # before_save { self.email = email.downcase } # email = email.downcaseだと動かない
  before_save { email.downcase! } # email = email.downcaseだと動かない
  validates :name, presence: true, length: { maximum: 50 }
  # ドットの連続を誤りとして検出できない
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    # 一意性検証では大文字小文字を区別しない
                    uniqueness: { case_sensitive: false }
  # gemのbcryptをinstall
  # セキュアにハッシュ化したパスワードを、データベース内のpassword_digestという属性に保存
  # 仮想的な属性 (passwordとpassword_confirmation) が使える
  # 存在性と値が一致するかどうかのバリデーションも追加
  # authenticateメソッドが使える
  # 引数の文字列がパスワードと一致するとUserオブジェクトを、間違っているとfalseを返す
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }

  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
end
