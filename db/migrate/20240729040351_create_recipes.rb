class CreateRecipes < ActiveRecord::Migration[7.1]
  def change
    create_table :recipes do |t|
      t.string :name
      t.integer :cooking_time_minutes
      t.text :ingredients
      t.text :instructions
      t.float :calories
      t.float :protein
      t.float :carbs
      t.float :fat
      t.float :fiber

      t.timestamps
    end
  end
end
