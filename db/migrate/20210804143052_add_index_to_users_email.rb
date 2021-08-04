class AddIndexToUsersEmail < ActiveRecord::Migration[5.1]
  def change
    # 多数のデータがあるときの検索効率を向上させる
    add_index :users, :email, unique: true
  end
end
