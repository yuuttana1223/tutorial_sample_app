class User < ApplicationRecord
  # ユーザーが破棄された場合、ユーザーのマイクロポストも同様に破棄される
  has_many :microposts, dependent: :destroy

  attr_accessor :remember_token, :activation_token, :reset_token

  # データベースに保存する前(作成時や更新時)にemail属性を強制的に小文字に変換
  # email = email.downcaseだと動かない
  # before_save { self.email = email.downcase } # email = email.downcaseだとローカル変数と認識される
  before_save :downcase_email
  # 作成されたときだけ
  before_create :create_activation_email
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
  # allow_nilは2つの同じエラーメッセージが表示されるというバグを解決するため
  # has_secure_passwordのvalidationとかぶるため
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  def self.digest(string)
    # GitHubのコードから参照(Gemのbcryptでhas_secure_password)
    # 暗号化の計算回数(2^cost 回)
    # min_cost は通常は false テスト環境時のみ、trueなのでテストは暗号化は最低限
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # ランダムなトークンを返す
  def self.new_token
    SecureRandom.urlsafe_base64
  end

  # 永続セッションのためにユーザーをデータベースに記憶する
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # 渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(attribute, token)
    # selfはなくても良い
    digest = self.send("#{attribute}_digest")
    return false if digest.nil?
    # self.remember_digestと同じ意味
    BCrypt::Password.new(digest).is_password?(token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  # アカウントを有効にする
  def activate
    # update_attributeが２回呼ばれるのでデータベースに二回アクセスしてしまう
    # バリデーションやコールバックが行われない
    # update_attribute(:is_activated, true)
    # update_attribute(:activated_at, Time.zone.now)

    # update_attributesはバリデーションやコールバックが行われるが
    # update_columnsは行われない
    # update_columns(is_activated: true, activated_at: Time.zone.now)
    update_attributes(is_activated: true, activated_at: Time.zone.now)
  end

  # 有効化用のメールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # パスワード再設定の属性を設定する
  def create_reset_digest
    self.reset_token = User.new_token
    update_attributes(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
  end

  # パスワード再設定のメールを送信する
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # パスワード再設定の期限が切れている場合はtrueを返す
  def password_reset_expired?
    # 現在時刻より2時間以上前 (早い) の場合
    # 現在の時間が2時間経たないと2.hours.agoが大きくならない
    reset_sent_at < 2.hours.ago
  end

  # 試作feedの定義
  # 完全な実装は次章の「ユーザーをフォローする」を参照
  def feed
    # SQLインジェクションを避ける
    # 特別な意味をもつ文字・記号(', ;)が入力された際に、別の文字列に書き換えてしまう
    Micropost.where("user_id = ?", id)
  end

  private

  def downcase_email
    email.downcase!
  end

  # 有効化トークンとダイジェストを作成および代入する
  def create_activation_email
    # ランダムな文字列生成
    self.activation_token = User.new_token
    # ランダムの文字列を暗号化
    self.activation_digest = User.digest(activation_token)
  end
end
