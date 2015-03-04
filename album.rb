class Album < HacktiveRecord::Base
  belongs_to :artist
  has_many :songs
end
