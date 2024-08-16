class CreateNutritionLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :nutrition_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.float :calories
      t.float :protein
      t.float :fat
      t.float :carbs
      t.float :fiber
      t.date :date

      t.timestamps
    end
  end
end
