class CreateVersionsTables < ActiveRecord::Migration
  def change
    create_table :los_versions do |t|
    	t.string :name
    	t.text :description 
    	t.integer :introductions_count
    	t.integer :exercises_count
    	t.string  :image_file_name
    	t.string   :image_content_type
    	t.integer  :image_file_size
    	t.datetime :image_updated_at
    	t.references :user, foreign_key: true
    	t.references :lo, foreign_key: true
        t.column :created_at, :datetime
    end

    create_table :introductions_versions do |t|
	t.string :title
	t.text :content
	t.integer :position
	t.integer :lo_id, index: true, foreign_key: true
	t.references :introduction, foreign_key: true
	t.column :created_at, :datetime
    end 

    create_table :exercises_versions do |t|
        t.string :title
        t.text :content
        t.integer :position
        t.integer :questions_count
        t.integer :lo_id, index: true, foreign_key: true
        t.references :exercise, foreign_key: true
        t.column :created_at, :datetime
    end 

    create_table :questions_versions do |t|
        t.string :title
        t.text :content
        t.text :correct_answer
        t.integer :position
        t.integer :precision
        t.boolean :cmas_order
        t.integer :exercise_id, index: true, foreign_key: true
        t.references :question, foreign_key: true
        t.column :created_at, :datetime
    end 

    create_table :tips_versions do |t|
        t.string :content
        t.integer :number_of_tries
        t.integer :question_id, index: true, foreign_key: true
        t.integer :tip_id, index: true, foreign_key: true
    end

    add_reference :answers, :los_version, foreign_key: true
    add_reference :answers, :exercises_version, foreign_key: true
    add_reference :answers, :questions_version, foreign_key: true

    add_column :answers, :introductions_versions, :integer, array: true, default: []
    add_column :answers, :exercises_versions, :integer, array: true, default: []
    add_column :answers, :last_answers, :integer, array: true, default: []
    
    add_column :exercises_versions, :questions_versions, :integer, array: true, default: []
    
    add_column :questions_versions, :tips_versions, :integer, array: true, default: []

    add_column :los, :modified, :boolean
    add_column :introductions, :modified, :boolean
    add_column :exercises, :modified, :boolean
    add_column :questions, :modified, :boolean
    add_column :tips, :modified, :boolean

  end
end
