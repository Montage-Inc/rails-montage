class Movie < MontageRails::Base
  has_many :actors

  belongs_to :studio

  attr_accessor :before_save_var, :before_create_var, :after_save_var, :after_create_var

  before_save :do_stuff
  before_create :do_other_stuff
  after_save :do_stuff_after_save
  after_create :do_stuff_after_create

  validates :title, presence: true

  def do_stuff
    @before_save_var = "FOO"
  end

  def do_other_stuff
    @before_create_var = "BAR"
  end

  def do_stuff_after_save
    @after_save_var = "AFTER SAVE"
  end

  def do_stuff_after_create
    @after_create_var = "AFTER CREATE"
    self.votes = 600
    save!
  end
end
