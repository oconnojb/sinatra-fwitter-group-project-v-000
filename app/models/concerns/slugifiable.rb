module Slugifiable
  module InstanceMethods
    def slug
      string = self.username.downcase.split.join("-")
      string
    end
  end

  module ClassMethods
    def unslug(slug)
      array = slug.split("-")
      n_array = []
      array.each do |item|
        n_array << item
      end
      n_array.join(" ")
    end

    def find_by_slug(slug)
      result = unslug(slug)
      self.find_by(username: result)
    end
  end
end
