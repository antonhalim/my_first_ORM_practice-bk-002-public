require_relative 'environment'
require 'rspec'
DBConnection.instance.dbname = 'hacktive_record_test'

describe 'All the things' do
  before do
    `psql -f seed.sql -d hacktive_record_test`
  end

  after do
    `psql -f drop.sql -d hacktive_record_test`
  end

  describe Album do
    it ".all returns all albums" do
      expect(Album.all.count).to eq(4)
    end

    it ".find finds by id" do
      expect(Album.find(1).name).to eq("The Slim Shady LP")
    end

    it "saves new records" do
      album = Album.new(name: "New thing")
      album.save
      expect(album.id).to eq("5")
    end

    it "updates existing records" do
      album = Album.find(1)
      album.name = "A Newer thing"
      album.save
      expect(Album.find(1).name).to eq("A Newer thing")
    end

    it "knows its artist" do
      expect(Album.find(1).artist.name).to eq("Eminem")
    end

    it "knows its songs" do
      expect(Album.find(1).songs.first.title).to eq("My Name Is")
      expect(Album.find(1).songs.count).to eq(3)
    end
  end

  describe Artist do
    it ".all returns all artists" do
      expect(Artist.all.count).to eq(2)
    end

    it ".find finds by id" do
      expect(Artist.find(1).name).to eq("Eminem")
    end

    it "saves new records" do
      artist = Artist.new(name: "New thing")
      artist.save
      expect(artist.id).to eq("3")
    end

    it "updates existing records" do
      artist = Artist.find(1)
      artist.name = "A Newer thing"
      artist.save
      expect(Artist.find(1).name).to eq("A Newer thing")
    end

    it "knows its albums" do
      expect(Artist.find(1).albums.first.name).to eq("The Slim Shady LP")
      expect(Artist.find(1).albums.count).to eq(2)
    end
  end
  describe Song do
    it ".all returns all songs" do
      expect(Song.all.count).to eq(7)
    end

    it ".find finds by id" do
      expect(Song.find(1).title).to eq("My Name Is")
    end

    it "saves new records" do
      song = Song.new(title: "New thing")
      song.save
      expect(song.id).to eq("8")
    end

    it "updates existing records" do
      song = Song.find(1)
      song.title = "A Newer thing"
      song.save
      expect(Song.find(1).title).to eq("A Newer thing")
    end

    it "knows its album" do
      expect(Song.find(1).album.name).to eq("The Slim Shady LP")
    end
  end
end
